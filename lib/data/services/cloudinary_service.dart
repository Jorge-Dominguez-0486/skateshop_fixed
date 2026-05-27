import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String _cloudName = 'djfzhfrjh';
  static const String _uploadPreset = 'alejandro';
  static const String _baseUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  static Future<String?> pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return null;
    return _uploadXFile(image);
  }

  static Future<String?> pickFromCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image == null) return null;
    return _uploadXFile(image);
  }

  /// Sube usando bytes — compatible con Web, Android e iOS.
  static Future<String?> _uploadXFile(XFile file) async {
    final bytes = await file.readAsBytes();
    final fileName = file.name.isNotEmpty ? file.name : 'upload.jpg';

    final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
    request.fields['upload_preset'] = _uploadPreset;
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      ),
    );

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode != 200) {
      throw Exception('Cloudinary error ${streamed.statusCode}: $body');
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['secure_url'] as String?;
  }

  static Future<String?> uploadFromUrl(String imageUrl) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      body: {
        'upload_preset': _uploadPreset,
        'file': imageUrl,
      },
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Cloudinary error ${response.statusCode}: ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['secure_url'] as String?;
  }
}
