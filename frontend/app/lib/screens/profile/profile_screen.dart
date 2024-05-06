import 'package:app/widgets/card/common_card.dart';
import 'package:app/widgets/header/header.dart';
import 'package:app/widgets/navigator/common_navigation_bar.dart';
import 'package:app/widgets/profile/icon_with_text.dart';
import 'package:app/widgets/profile/logout_button.dart';
import 'package:app/widgets/profile/my_activity.dart';
import 'package:app/widgets/profile/my_info.dart';
import 'package:app/widgets/profile/my_loto.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/main');
    }
    if (index == 1) {
      Navigator.pushNamed(context, '/nfc');
    }
    if (index == 2) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  titleStyle() {
    return const TextStyle(fontWeight: FontWeight.bold, fontSize: 25);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: '프로필', back: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const MyInfo(),
                LogoutButton()],
            ),
          ),
          const Divider(color: Colors.grey, thickness: 1.0,),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('내 활동', style: titleStyle()),
                const SizedBox(height: 10,),
                const MyActivity(),
              ],
            ),
          ),
          const Divider(color: Colors.grey, thickness: 1.0,),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text('나의 LOTO', style: titleStyle()),
          ),
          const SizedBox(height: 10,),
          MyLoto()
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}