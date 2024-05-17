import 'dart:async';
import 'dart:convert';

import 'package:app/view_models/core/core_check_view_model.dart';
import 'package:app/view_models/core/core_issue_view_model.dart';
import 'package:app/view_models/core/core_locked_view_model.dart';
import 'package:app/view_models/core/core_unlock_view_model.dart';
import 'package:app/widgets/bluetooth/scan_result_tile.dart';
import 'package:app/widgets/button/common_text_button.dart';
import 'package:app/widgets/dialog/dialog.dart';
import 'package:app/widgets/header/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final _storage = const FlutterSecureStorage();
  List<ScanResult> _scanResults = [];
  List<ScanResult> _lastScanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  List<String> _receivedValues = [];
  String? companyCode;
  String? coreCode;
  String? lockerToken;
  String? machineId;
  String? userId;
  String? lockerUid;
  BluetoothService? bluetoothService;
  BluetoothCharacteristic? bluetoothCharacteristic;
  bool _isLocking = false;
  bool _isUnlocking = false;

  @override
  void initState() {
    super.initState();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      debugPrint(e);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });

    _lastScanResults = FlutterBluePlus.lastScanResults;
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future onScanPressed() async {
    // _storage.delete(key: 'Core-Code');
    // _storage.delete(key: 'locker_battery');
    // _storage.delete(key: 'machine_id');
    // _storage.delete(key: 'locker_token');
    // _storage.delete(key: 'locker_uid');
    try {
      await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 5), withKeywords: ["SEOLO"]);
    } catch (e) {
      debugPrint("Start Scan Error: $e");
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint("Stop Scan Error: $e");
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    FlutterBluePlus.stopScan();
    await writeToDevice(device);
  }

  Future<void> writeToDevice(BluetoothDevice device) async {
    final issueVM = Provider.of<CoreIssueViewModel>(context, listen: false);
    final checkVM = Provider.of<CoreCheckViewModel>(context, listen: false);
    final lockedVM = Provider.of<CoreLockedViewModel>(context, listen: false);
    final unlockVM = Provider.of<CoreUnlockViewModel>(context, listen: false);
    bool hasExecutedCoreIssued = false; // 함수 중복 방지
    bool hasExecutedCoreLocked = false;
    bool hasExecutedCoreUnlock = false;
    bool hasExecutedCoreCheck = false;
    bool hasExecutedAlert = false;
    await device.discoverServices().then((services) async {
      companyCode = await _storage.read(key: 'Company-Code');
      coreCode = await _storage.read(key: 'Core-Code');
      lockerToken = await _storage.read(key: 'locker_token');
      machineId = await _storage.read(key: 'machine_id');
      userId = await _storage.read(key: 'user_id');
      lockerUid = await _storage.read(key: 'locker_uid');
      // code가 write라면 init을 보냈는데 그 뒤에 꺼졌을 때
      if (coreCode == 'WRITE') {
        await _storage.delete(key: 'locker_uid');
        await _storage.delete(key: 'locker_battery');
        await _storage.write(key: 'Core-Code', value: 'INIT');
        coreCode = 'INIT';
      }
      for (var service in services) {
        if (service.uuid.toString().toUpperCase() ==
            "20240520-C104-C104-C104-012345678910") {
          bluetoothService = service;
          List<BluetoothCharacteristic> characteristics =
              service.characteristics;
          for (var characteristic in characteristics) {
            if (characteristic.uuid.toString().toUpperCase() ==
                "20240521-C104-C104-C104-012345678910") {
              bluetoothCharacteristic = characteristic;
              debugPrint('쓰기 시도');
              //회사코드 토큰 장비 유저 uid coreCode
              String message =
                  "${companyCode ?? ''},${lockerToken ?? ''},${machineId ?? ''},${userId ?? ''},${lockerUid ?? ''},${coreCode ?? 'INIT'}";
              debugPrint('보내는 값: $message');
              List<int> encodedMessage = utf8.encode(message);
              try {
                await characteristic.write(encodedMessage,
                    // withoutResponse:
                    // characteristic.properties.writeWithoutResponse,
                    allowLongWrite: true,
                    timeout: 30);
                // 잠금 요청을 보냈을 시 응답값이 올 동안 loading screen
                if (coreCode == "LOCK") {
                  _isLocking = true;
                }
                // // 잠금 해제도 마찬가지로 loading screen
                // // LOCKED의 경우 받을 수 있는 행동코드 2가지 (UNLOCK, CHECK)
                if (coreCode == "LOCKED") {
                  _isUnlocking = true;
                }
                characteristic.setNotifyValue(true);
                characteristic.read();
                characteristic.lastValueStream.listen((value) async {
                  String receivedString = utf8.decode(value);
                  _receivedValues = receivedString.split(',');
                  // 코드 uid 장비 배터리 유저id
                  debugPrint('응답값: $receivedString');
                  if (_receivedValues[4] == userId) {
                    if (mounted) {
                      if (_receivedValues[0] == 'ALERT' && !hasExecutedAlert) {
                        hasExecutedAlert = true;
                        showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return CommonDialog(
                                content: '연결할 자물쇠를 확인해 주세요.',
                                buttonText: '확인',
                              );
                            });
                      } else {
                        // CHECK거나 ALERT가 아니면 code 덮기
                        if (_receivedValues[0] != 'CHECK') {
                          await _storage.write(
                              key: 'Core-Code', value: _receivedValues[0]);
                        }
                        await _storage.write(
                            key: 'locker_uid', value: _receivedValues[1]);
                        await _storage.write(
                            key: 'machine_id', value: _receivedValues[2]);
                        await _storage.write(
                            key: 'locker_battery', value: _receivedValues[3]);
                      }
                      // 작업 내역을 미리 작성했다면
                      if (_receivedValues[0] == 'WRITED' &&
                          !hasExecutedCoreIssued) {
                        String? battery =
                            await _storage.read(key: 'locker_battery');
                        int? batteryInfo =
                            (battery != null) ? int.parse(battery) : 0;
                        issueVM.setBattery(batteryInfo);
                        String? lockerUid =
                            await _storage.read(key: 'locker_uid');
                        (lockerUid != null)
                            ? issueVM.setLockerUid(lockerUid)
                            : issueVM.setLockerUid('');
                        hasExecutedCoreIssued = true;
                        issueVM.coreIssue().then((_) {
                          if (issueVM.errorMessage == null) {
                            writeToDevice(device);
                          } else {
                            if (issueVM.errorMessage == 'JT') {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return CommonDialog(
                                      content: '토큰이 만료되었습니다. 다시 로그인 해주세요.',
                                      buttonText: '확인',
                                      buttonClick: () {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/login',
                                            (route) => false);
                                      },
                                    );
                                  });
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CommonDialog(
                                      content: issueVM.errorMessage!,
                                      buttonText: '확인',
                                    );
                                  });
                            }
                          }
                        });
                      }
                      if (_receivedValues[0] == 'WRITE') {
                        Navigator.pushReplacementNamed(context, '/checklist');
                        hasExecutedCoreIssued = true;
                      }
                      if (_receivedValues[0] == 'CHECK' &&
                          !hasExecutedCoreCheck) {
                        // locked에서 check로 왔다면 상태 되돌리기
                        if (coreCode == "LOCKED") {
                          _isUnlocking = false;
                        }
                        hasExecutedCoreCheck = true;
                        checkVM.coreCheck().then((_) {
                          if (checkVM.errorMessage == null) {
                            Navigator.pushReplacementNamed(
                                context, '/otherWorklistCheck');
                          } else {
                            if (checkVM.errorMessage == 'JT') {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return CommonDialog(
                                      content: '토큰이 만료되었습니다. 다시 로그인 해주세요.',
                                      buttonText: '확인',
                                      buttonClick: () {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/login',
                                            (route) => false);
                                      },
                                    );
                                  });
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CommonDialog(
                                      content: checkVM.errorMessage!,
                                      buttonText: '확인',
                                    );
                                  });
                            }
                          }
                        });
                      }
                      if (_receivedValues[0] == 'UNLOCK' &&
                          !hasExecutedCoreUnlock) {
                        _isUnlocking = false;
                        hasExecutedCoreUnlock = true;
                        unlockVM.coreUnlock().then((_) {
                          if (unlockVM.errorMessage == null) {
                            // Navigator.pushNamed(context, '/resultUnlock');
                            // Navigator.pushNamedAndRemoveUntil(context,
                            //     '/resultUnlock', ModalRoute.withName('/main'));
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/resultUnlock',
                                  (Route<dynamic> route) => route.isFirst,
                            );
                          } else {
                            if (unlockVM.errorMessage == 'JT') {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return CommonDialog(
                                      content: '토큰이 만료되었습니다. 다시 로그인 해주세요.',
                                      buttonText: '확인',
                                      buttonClick: () {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/login',
                                            (route) => false);
                                      },
                                    );
                                  });
                            } else {
                              // Navigator.pushNamed(context, '/resultUnlock');
                              // Navigator.pushNamedAndRemoveUntil(
                              //     context,
                              //     '/resultUnlock',
                              //     ModalRoute.withName('/main'));
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/resultUnlock',
                                    (Route<dynamic> route) => route.isFirst,
                              );
                            }
                          }
                        });
                      }
                      if (_receivedValues[0] == 'LOCKED' &&
                          !hasExecutedCoreLocked) {
                        _isLocking = false;
                        hasExecutedCoreLocked = true;
                        lockedVM.coreLocked().then((_) {
                          if (lockedVM.errorMessage == null) {
                            // Navigator.pushNamed(context, '/resultLock');
                            // Navigator.pushNamedAndRemoveUntil(context,
                            //     '/resultLock', ModalRoute.withName('/main'));
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/resultLock',
                                  (Route<dynamic> route) => route.isFirst,
                            );
                          } else {
                            if (lockedVM.errorMessage == 'JT') {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return CommonDialog(
                                      content: '토큰이 만료되었습니다. 다시 로그인 해주세요.',
                                      buttonText: '확인',
                                      buttonClick: () {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/login',
                                            (route) => false);
                                      },
                                    );
                                  });
                            } else {
                              // Navigator.pushNamed(context, '/resultLock');
                              // Navigator.pushNamedAndRemoveUntil(context,
                              //     '/resultLock', ModalRoute.withName('/main'));
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/resultLock',
                                    (Route<dynamic> route) => route.isFirst,
                              );
                            }
                          }
                        });
                      }
                    }
                  }
                });
              } catch (e) {
                debugPrint('write error: $e');
              }
            }
          }
        }
      }
    });
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 5), withKeywords: ["SEOLO"]);
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return CommonTextButton(text: '검색 중', onTap: onStopPressed);
    } else {
      return CommonTextButton(text: '연결 가능한 자물쇠 찾기', onTap: onScanPressed);
    }
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () {
              connectToDevice(r.device);
            },
          ),
        )
        .toList();
  }

  List<Widget> _buildLastScanResultTiles(BuildContext context) {
    return _lastScanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () => connectToDevice(r.device),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: '자물쇠 선택', back: true),
      body: (_isLocking == true || _isUnlocking == true)
          ? Center(
              child: Image.asset(
              'assets/images/loading_icon.gif',
              width: 200,
              height: 200,
            ))
          : RefreshIndicator(
              onRefresh: onRefresh,
              child: Stack(
                children: [
                  ListView(
                    children: <Widget>[
                      Text('receive: $_receivedValues'),
                      Text('최근 연결한 자물쇠'),
                      ..._buildLastScanResultTiles(context),
                      Text('새로운 자물쇠'),
                      ..._buildScanResultTiles(context),
                    ],
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 20, left: 50, right: 50),
                          child: buildScanButton(context)))
                ],
              ),
            ),
    );
  }
}
