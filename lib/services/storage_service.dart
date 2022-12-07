import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static Future<String?> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final storageRef = storage.ref('profileImages/$fileName');
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  static Future<void> retrieveFile(String filePath, String fileName) async {
    File file = File(filePath);
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      // await storage.ref('test/$fileName').(file);
    } catch (e) {}
  }
}
