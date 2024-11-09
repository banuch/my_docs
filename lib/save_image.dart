
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'image_strings.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  final ImagePicker _picker = ImagePicker();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();

  File? _image;

  // Function to show dialog to select image source
  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose Image Source"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromCamera();
              },
              child: const Text("Camera"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
              child: const Text("Gallery"),
            ),
          ],
        );
      },
    );
  }

  // Function to pick an image from the camera
  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Function to save multiple persons' details securely
  Future<void> _saveData() async {
    if (_nameController.text.isEmpty || _relationController.text.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      final File savedImage = await _image!.copy(filePath);

      // Create new person details map
      final personDetails = {
        'name': _nameController.text,
        'relation': _relationController.text,
        'imagePath': savedImage.path,
      };

      // Retrieve existing list from storage
      String? data = await _secureStorage.read(key: 'persons_list');
      List<dynamic> personsList = data != null ? jsonDecode(data) : [];

      // Add new entry and save back to storage
      personsList.add(personDetails);
      await _secureStorage.write(key: 'persons_list', value: jsonEncode(personsList));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully')),
      );

      // Clear inputs
      _nameController.clear();
      _relationController.clear();
      setState(() {
        _image = null;
      });
    } catch (e) {
      print('Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: const Text('Add Person Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: _showImageSourceDialog,
                child: _image != null
                    ? ClipOval(
                  child: Image.file(
                    _image!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
                    : ClipOval(
                  child: Image.asset(
                    tDefaultImage,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _relationController,
                decoration: const InputDecoration(
                  labelText: 'Relation',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Save'),
              ),
              const SizedBox(height: 10),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => DetailsScreen()),
              //     );
              //   },
              //   child: Text('View Saved Details'),
              //   style: ElevatedButton.styleFrom(
              //     minimumSize: Size(double.infinity, 50),
              //   ),
              // ),
            ],
          ),
        ),
      ),

    );
  }
}


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// import 'image_strings.dart';
//
// class ImagePickerScreen extends StatefulWidget {
//   @override
//   _ImagePickerScreenState createState() => _ImagePickerScreenState();
// }
//
// class _ImagePickerScreenState extends State<ImagePickerScreen> {
//   final ImagePicker _picker = ImagePicker();
//   final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
//
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _relationController = TextEditingController();
//
//   File? _image;
//
//   // Function to show dialog to select image source
//   Future<void> _showImageSourceDialog() async {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Choose Image Source"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _pickImageFromCamera();
//               },
//               child: Text("Camera"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _pickImageFromGallery();
//               },
//               child: Text("Gallery"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Function to pick an image from the camera
//   Future<void> _pickImageFromCamera() async {
//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }
//
//   // Function to pick an image from the gallery
//   Future<void> _pickImageFromGallery() async {
//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }
//
//   // Function to save the image and details securely
//   Future<void> _saveData() async {
//     if (_nameController.text.isEmpty ||
//         _relationController.text.isEmpty ||
//         _image == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please fill all fields and select an image')),
//       );
//       return;
//     }
//
//     try {
//       final Directory appDir = await getApplicationDocumentsDirectory();
//       final String filePath =
//           '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
//       final File savedImage = await _image!.copy(filePath);
//
//       // Save the image path, name, and relation securely
//       await _secureStorage.write(
//           key: 'saved_image_path', value: savedImage.path);
//       await _secureStorage.write(key: 'name', value: _nameController.text);
//       await _secureStorage.write(
//           key: 'relation', value: _relationController.text);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Data saved successfully')),
//       );
//     } catch (e) {
//       print('Error saving data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save data')),
//       );
//     }
//   }
//
//   // Function to retrieve and display the saved data
//   Future<void> _loadSavedData() async {
//     String? imagePath = await _secureStorage.read(key: 'saved_image_path');
//     String? name = await _secureStorage.read(key: 'name');
//     String? relation = await _secureStorage.read(key: 'relation');
//
//     if (imagePath != null) {
//       setState(() {
//         _image = File(imagePath);
//         _nameController.text = name ?? '';
//         _relationController.text = relation ?? '';
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedData(); // Load saved data on startup
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add Person')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               InkWell(
//                 onTap: _showImageSourceDialog,
//                 child: _image != null
//                     ? ClipOval(
//                         child: Image.file(
//                           _image!,
//                           width: 200,
//                           height: 200,
//                           fit: BoxFit.cover,
//                         ),
//                       )
//                     : ClipOval(
//                         child: Image.asset(
//                           tDefaultImage, // Add a default image to your assets folder
//                           width: 100,
//                           height: 100,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Name',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 20),
//               TextField(
//                 controller: _relationController,
//                 decoration: const InputDecoration(
//                   labelText: 'Relation',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _saveData,
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(double.infinity, 50), // Full-width button
//                 ),
//                 child: Text('Save'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
