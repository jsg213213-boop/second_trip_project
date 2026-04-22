import 'package:flutter/material.dart';
import '../loging/screens/search/search_screen.dart'; // 숙소
import '../airport/screen/search_screen.dart';         // 항공권

class TotalSearchScreen extends StatefulWidget {
  const TotalSearchScreen({super.key});

  @override
  State<TotalSearchScreen> createState() => _TotalSearchScreenState();
}

class _TotalSearchScreenState extends State<TotalSearchScreen> {
  int _currentIndex = 0;

  // 렌터카를 제거하고 숙소와 항공권만 남김
  final List<Widget> _pages = const [
    SearchScreen(),           // 0: 숙소
    AirpostSearchScreen(),    // 1: 항공권
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.hotel), label: '숙소'),
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: '항공권'),
        ],
      ),
    );
  }
}
