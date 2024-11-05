import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  AppDrawer({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Get the height of the screen
    double screenHeight = MediaQuery.of(context).size.height;

    // Adjust the drawer size based on screen height
    double drawerHeight =
        screenHeight < 600 ? screenHeight * 0.7 : screenHeight * 0.9;

    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Ensure logout is at the bottom
        children: <Widget>[
          // Upper part of the drawer
          Container(
            height: drawerHeight, // Set dynamic height for the drawer
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                // Adjust the red background here
                Container(
                  color: Colors.black, // Red background
                  padding: EdgeInsets.all(16.0), // Adjust padding as needed
                  child: Row(
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
                ),
                ListTile(
                  leading: Icon(Icons.home,
                      color: currentIndex == 0 ? Colors.red : Colors.white),
                  title: Text('All Services',
                      style: TextStyle(
                          color:
                              currentIndex == 0 ? Colors.red : Colors.white)),
                  onTap: () {
                    onTap(0); // Change page index
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_circle,
                      color: currentIndex == 1 ? Colors.red : Colors.white),
                  title: Text('Business Verification',
                      style: TextStyle(
                          color:
                              currentIndex == 1 ? Colors.red : Colors.white)),
                  onTap: () {
                    onTap(1);
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings,
                      color: currentIndex == 2 ? Colors.red : Colors.white),
                  title: Text('Normal Users',
                      style: TextStyle(
                          color:
                              currentIndex == 2 ? Colors.red : Colors.white)),
                  onTap: () {
                    onTap(2);
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help,
                      color: currentIndex == 3 ? Colors.red : Colors.white),
                  title: Text('Merchant Users',
                      style: TextStyle(
                          color:
                              currentIndex == 3 ? Colors.red : Colors.white)),
                  onTap: () {
                    onTap(3);
                    Navigator.pop(context); // Close the drawer
                  },
                ),
              ],
            ),
          ),
          // Logout button at the bottom
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              // Call the logout function and go to LoginPage
              await FirebaseAuth.instance.signOut(); // Firebase logout
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false); // Clear login state

              // Navigate to LoginPage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
