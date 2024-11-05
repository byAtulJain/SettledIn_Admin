import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'home_page.dart';
import 'business_verification.dart';
import 'all_users.dart';
import 'all_merchants.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late List<Widget> _pages;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Initialize the pages list
    _pages = [
      HomePage(),
      AdminBusinessVerificationPage(),
      AllUsersPage(),
      AllMerchantsPage(),
    ];

    _controller.forward(); // Start the animation on page load
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _controller.reset();
      _controller.forward(); // Reset animation and trigger the fade transition
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              "Settled",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white, // White text for AppBar
              ),
            ),
            Text(
              "In",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black, // Set the AppBar color to black
        iconTheme: IconThemeData(
          color: Colors.red, // Set the hamburger icon color to red
        ),
      ),
      drawer: AppDrawer(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: FadeTransition(
          opacity: _animation,
          child: _pages[_currentIndex],
        ),
      ),
      backgroundColor: Colors.black, // Keep the consistent background color
    );
  }
}
