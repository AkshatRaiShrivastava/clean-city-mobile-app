import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:cleancity/config/cloudinary_config.dart';

class CloudinaryService {
  static final cloudinary = CloudinaryPublic(
    CloudinaryConfig.cloudName,
    CloudinaryConfig.uploadPreset,
    cache: false,
  );

  static Future<String> uploadImage(File imageFile) async {
    try {
      debugPrint('Starting image upload to Cloudinary...');

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: CloudinaryConfig.folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      debugPrint('Image uploaded successfully. URL: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      debugPrint('Cloudinary Upload Error: $e');
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }
}
