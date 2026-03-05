import 'package:flutter/material.dart';

// Import the two screens we have already built!
import 'home_screen.dart';
import 'inbox_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // This variable keeps track of which tab is currently selected.
  // 0 = Match Screen, 4 = Messages Screen
  int _currentIndex = 0;

  // This list holds the 5 screens that correspond to your 5 icons!
  final List<Widget> _screens = [
    const HomeScreen(), // 0: The swiping matrix
    
    // 1, 2, and 3 are placeholders until we build them!
    const Center(child: Text("MAP SCREEN COMING SOON", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    const Center(child: Text("CREATE SCREEN COMING SOON", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    const Center(child: Text("UNIVERSE SCREEN COMING SOON", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    
    const InboxScreen(), // 4: The beautiful messaging inbox
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // The body simply displays whichever screen matches the _currentIndex
      body: _screens[_currentIndex],
      
      // The Bottom Navigation Bar from your wireframe!
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // When an icon is tapped, update the index and redraw the screen!
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed, // Prevents icons from moving around
          backgroundColor: Colors.white,
          selectedItemColor: Colors.pinkAccent,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: false, // Hides text to match your clean sketch
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            // 1. Match Screen (Using layers icon to look like swipe cards)
            BottomNavigationBarItem(
              icon: Icon(Icons.style_outlined, size: 28), 
              label: "Match",
            ),
            // 2. Map (Globe icon)
            BottomNavigationBarItem(
              icon: Icon(Icons.public, size: 28), 
              label: "Map",
            ),
            // 3. Create (Plus icon)
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, size: 32), 
              label: "Create",
            ),
            // 4. Universe (Explore icon)
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined, size: 28), 
              label: "Universe",
            ),
            // 5. Messages (Chat bubble icon)
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline, size: 28), 
              label: "Message",
            ),
          ],
        ),
      ),
    );
  }
}