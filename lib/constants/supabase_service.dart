import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<String?> uploadImage(File file, String bucketName) async {
    try {
      final storage = Supabase.instance.client.storage;

      // Generate a unique filename
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload the file
      final response = await storage.from(bucketName).upload(fileName, file);

      // Check if the upload was successful
      if (response.isEmpty) {
        throw Exception('Upload failed');
      }

      // Get the public URL of the uploaded image
      final publicUrl = storage.from(bucketName).getPublicUrl(fileName);

      print('Image uploaded successfully. Public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}
