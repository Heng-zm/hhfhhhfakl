import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UploadAndSendImage(),
    );
  }
}

class UploadAndSendImage extends StatefulWidget {
  @override
  _UploadAndSendImageState createState() => _UploadAndSendImageState();
}

class _UploadAndSendImageState extends State<UploadAndSendImage> {
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();
  final String botToken =
      "6941579931:AAHJRb_kYDxxutmPJ7ji6F5p_laP1LjOnAA"; // Replace with your bot token
  final String chatId = "1272791365"; // Replace with your chat ID

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      } else {
        print("No image selected.");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Send the image and caption to Telegram
  Future<void> _sendImageToTelegram() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No image selected to send!")),
      );
      return;
    }

    try {
      var url = Uri.parse("https://api.telegram.org/bot$botToken/sendPhoto");
      var request = http.MultipartRequest('POST', url)
        ..fields['chat_id'] = chatId
        ..fields['caption'] = _captionController.text // Add the caption here
        ..files.add(http.MultipartFile.fromBytes(
          'photo',
          _imageBytes!,
          filename: 'uploaded_image.jpg',
        ));

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image sent to Telegram successfully!")),
        );
        _captionController.clear(); // Clear the caption after sending
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to send image: ${response.reasonPhrase}")),
        );
      }
    } catch (e) {
      print("Error sending image to Telegram: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending image: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload and Send Image to Telegram"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display selected image
            _imageBytes != null
                ? Image.memory(
                    _imageBytes!,
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.grey[700],
                    ),
                  ),
            SizedBox(height: 20),

            // Caption input
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: "Enter caption",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Button to pick an image
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Upload Image"),
            ),

            SizedBox(height: 10),

            // Button to send the image and caption to Telegram
            ElevatedButton(
              onPressed: _sendImageToTelegram,
              child: Text("Send to Telegram"),
            ),
          ],
        ),
      ),
    );
  }
}
