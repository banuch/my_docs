import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:my_docs/all_documents.dart';
import 'package:my_docs/details_screen.dart';
import 'package:my_docs/save_image.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  Widget _getPage(int page) {
    switch (page) {
      case 0:
        return  const DetailsScreen();
      case 1:
        return AllDocumentsPage();
      case 2:
        return const Center(child: Text("List of Documents"));
      case 3:
        return const Center(child: Text("List of Documents"));
      case 4:
        return const Center(child: Text("Profile Page"));
      default:
        return const Center(child: Text("Home Page"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        items: const <Widget>[
          Icon(Icons.family_restroom, size: 30),

          Icon(Icons.category, size: 30),
          Icon(Icons.library_books_sharp, size: 30), // Corresponds to image_details page
          Icon(Icons.person, size: 30),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _page = index; // Update current page index
          });
        },
        letIndexChange: (index) => true,
      ),
      body: Container(
        color: Colors.blueAccent,
        child: _getPage(_page), // Dynamically load the current page
      ),
    );
  }
}
