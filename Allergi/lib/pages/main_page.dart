import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'barcode_page.dart';
import 'product_page.dart';
import 'restaurant_page.dart';
import 'allergy_page.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    BarcodePage(),
    ProductPage(),
    RestaurantPage(),
    AllergyPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: "바코드/이름",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "제품명",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: "안심 식당",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.healing),
            label: "내 알레르기",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "설정",
          ),
        ],
      ),
    );
  }
}
