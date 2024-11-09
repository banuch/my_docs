import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_docs/image_strings.dart';
import 'package:my_docs/save_image.dart';

import 'add_documents.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<Map<String, dynamic>> _personsList = [];

  // Load saved persons list
  Future<void> _loadSavedData() async {
    String? data = await _secureStorage.read(key: 'persons_list');
    if (data != null) {
      List<dynamic> decodedList = jsonDecode(data);
      setState(() {
        _personsList = List<Map<String, dynamic>>.from(decodedList);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _addDocument() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ImagePickerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Family Members'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addDocument,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _personsList.length,
        itemBuilder: (context, index) {
          final person = _personsList[index];
          final imagePath = person['imagePath'];
          final name = person['name'];
          final relation = person['relation'];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            // Add spacing around each tile
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent.shade100,
              // Set your desired background color
              borderRadius: BorderRadius.circular(12.0), // Rounded corners
            ),
            child: ListTile(
              leading: ClipOval(
                child: imagePath != null && File(imagePath).existsSync()
                    ? Image.file(
                        File(imagePath),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        tDefaultImage,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
              ),
              title: Text(name ?? 'No Name'),
              subtitle: Text(
                relation ?? 'No Relation',
                style: const TextStyle(
                    fontWeight: FontWeight.bold), // Make subtitle bold
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  // builder: (context) => AddDocumentPage(person: person),
                  builder: (context) => DocumentListPage(person: person),
                ),
              ),
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Action to perform when the button is pressed
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Press + Button ')),
      //     );
      //   },
      //   tooltip: 'Add',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
