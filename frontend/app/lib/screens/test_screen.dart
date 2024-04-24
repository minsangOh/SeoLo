import 'package:app/services/test_service.dart';
import 'package:app/widgets/common_icon_button.dart';
import 'package:app/widgets/common_text_button.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/common_navigation_bar.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _selectedIndex = 0;  // 현재 선택된 탭의 인덱스를 저장하는 변수

  void _onItemTapped(int index) {  // 탭이 눌렸을 때 호출할 메소드
    setState(() {
      _selectedIndex = index;  // 선택된 탭의 인덱스를 업데이트
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.start,
              children: [
                CommonIconButton(
                    text: 'NFC 태그',
                    iconImage: 'assets/images/nfc_tag_icon.png',
                    shape: BoxShape.rectangle,
                    onTap: () {
                      TestService testService = TestService();
                      testService.getTest();
                    }),
                CommonIconButton(
                    text: '정비',
                    iconImage: 'assets/images/maintenance_icon.png',
                    shape: BoxShape.circle,
                    onTap: () {}),
                CommonTextButton(text: '다음 단계', onTap: () {}),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/lock');
                  },
                  child: const Text('잠금화면'),
                ),
                CustomBottomNavigationBar(
                  selectedIndex: _selectedIndex,  // 현재 선택된 인덱스를 전달
                  onItemTapped: _onItemTapped,
                )
              ],
            ),
          ),
        ));
  }
}
