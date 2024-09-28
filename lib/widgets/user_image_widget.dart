
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImageWidget extends StatefulWidget {
  const UserImageWidget({super.key, required this.onSelectImage});

  final void Function(Uint8List image) onSelectImage;

  @override
  State<UserImageWidget> createState() => _UserImageWidgetState();
}

class _UserImageWidgetState extends State<UserImageWidget> {
  // File? _imagePicked; File? doesn't support web so we used Uint8list ND memory image

  Uint8List? _imagePicked;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) {
      return;
    }

    // _imagePicked = File(pickedImage.path);
    // setState(() {});

    // Read the image as bytes for web compatibility
    final imageBytes = await pickedImage.readAsBytes();

    setState(() {
      _imagePicked = imageBytes;
    });

   if (_imagePicked != null) {
    widget.onSelectImage(_imagePicked!);
  }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[350],
          foregroundImage: _imagePicked == null
              ? null
              :
              // FileImage(_imagePicked!),
              MemoryImage(_imagePicked!),
        ),
        TextButton.icon(
          onPressed: _pickImage,
          label: const Text('Add your image'),
          icon: const Icon(Icons.camera_alt_outlined),
        ),
      ],
    );
  }
}
