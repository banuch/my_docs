import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_filex/open_filex.dart';

class AllDocumentsPage extends StatefulWidget {
  @override
  _AllDocumentsPageState createState() => _AllDocumentsPageState();
}

class _AllDocumentsPageState extends State<AllDocumentsPage> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<Map<String, dynamic>> _allDocuments = [];

  @override
  void initState() {
    super.initState();
    _loadAllDocuments();
  }

  Future<void> _loadAllDocuments() async {
    // Load all persons and their documents from secure storage
    String? data = await _secureStorage.read(key: 'persons_list');
    if (data != null) {
      List<dynamic> personsList = jsonDecode(data);
      List<Map<String, dynamic>> documents = [];

      for (var person in personsList) {
        String personName = person['name'] ?? 'Unknown Person';
        List<dynamic> personDocuments = person['documents'] ?? [];

        for (var document in personDocuments) {
          // Add personName to document data for display
          Map<String, dynamic> docWithPersonName = {
            'personName': personName,
            ...document,
          };
          documents.add(docWithPersonName);
        }
      }

      setState(() {
        _allDocuments = documents;
      });
    }
  }

  Future<void> _openPdf(String filePath) async {
    final result = await OpenFilex.open(filePath);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open PDF.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text('All  Documents'),
      ),
      body: _allDocuments.isNotEmpty
          ? ListView.builder(
              itemCount: _allDocuments.length,
              itemBuilder: (context, index) {
                final document = _allDocuments[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  // Add spacing around each tile
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent.shade100,
                    // Set your desired background color
                    borderRadius:
                        BorderRadius.circular(12.0), // Rounded corners
                  ),
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf),
                    title: Text(document['name'] ?? 'Untitled Document'),
                    subtitle: Text(
                      '${document['type'] ?? 'Unknown Type'} - ${document['personName']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold), // Make subtitle bold
                    ),
                    onTap: () => _openPdf(document['filePath']),
                  ),
                );
              },
            )
          : Center(child: Text('No documents available')),
    );
  }
}
