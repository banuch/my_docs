import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';


class DocumentListPage extends StatefulWidget {
  final Map<String, dynamic> person;
  DocumentListPage({required this.person});

  @override
  _DocumentListPageState createState() => _DocumentListPageState();
}

class _DocumentListPageState extends State<DocumentListPage> {
  List<Map<String, dynamic>> _documentList = [];

  @override
  void initState() {
    super.initState();
    _loadDocumentList();
  }

  Future<void> _loadDocumentList() async {
    // Assuming 'documents' field exists in person with a list of documents
    setState(() {
      _documentList = List<Map<String, dynamic>>.from(widget.person['documents'] ?? []);
    });
  }

  Future<void> _addDocument() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDocumentPage(person: widget.person),
      ),
    );

    if (result != null) {
      setState(() {
        _documentList.add(result); // Add the new document to the list
        widget.person['documents'] = _documentList; // Update person data
      });

      // Save updated person data to secure storage
      final storage = FlutterSecureStorage();
      String? personsListData = await storage.read(key: 'persons_list');
      if (personsListData != null) {
        List<Map<String, dynamic>> personsList = List<Map<String, dynamic>>.from(jsonDecode(personsListData));
        int index = personsList.indexWhere((p) => p['name'] == widget.person['name']);
        if (index != -1) {
          personsList[index] = widget.person;
          await storage.write(key: 'persons_list', value: jsonEncode(personsList));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Add spacing around each tile
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent.shade100, // Set your desired background color
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Documents for ${widget.person['name']}'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _addDocument,
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: _documentList.length,
          itemBuilder: (context, index) {
            final document = _documentList[index];
            return ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text(document['name'] ?? 'Untitled Document'),
              subtitle: Text(document['type'] ?? 'Unknown Type'),
              onTap: () {
                // Code to open the PDF file goes here
              },
            );
          },
        ),
      ),
    );
  }
}

class AddDocumentPage extends StatefulWidget {
  final Map<String, dynamic> person;
  AddDocumentPage({required this.person});

  @override
  _AddDocumentPageState createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final TextEditingController _docNameController = TextEditingController();
  final TextEditingController _docTypeController = TextEditingController();
  File? _selectedFile;

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _saveDocument() async {
    if (_selectedFile != null && _docNameController.text.isNotEmpty && _docTypeController.text.isNotEmpty) {
      Map<String, dynamic> documentData = {
        'filePath': _selectedFile!.path,
        'name': _docNameController.text,
        'type': _docTypeController.text,
      };
      Navigator.pop(context, documentData); // Pass document data back
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Document for ${widget.person['name']}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _docNameController,
              decoration: InputDecoration(labelText: 'Document Name'),
            ),
            TextField(
              controller: _docTypeController,
              decoration: InputDecoration(labelText: 'Document Type'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickPdf,
              child: Text(_selectedFile != null ? 'Change PDF' : 'Select PDF'),
            ),
            if (_selectedFile != null) Text('Selected file: ${_selectedFile!.path}'),
            Spacer(),
            ElevatedButton(
              onPressed: _saveDocument,
              child: Text('Save Document'),
            ),
          ],
        ),
      ),
    );
  }
}
