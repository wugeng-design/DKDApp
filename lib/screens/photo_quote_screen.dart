import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dao_app/utils/app_theme.dart';

class PhotoQuoteScreen extends StatefulWidget {
  const PhotoQuoteScreen({super.key});

  @override
  State<PhotoQuoteScreen> createState() => _PhotoQuoteScreenState();
}

class _PhotoQuoteScreenState extends State<PhotoQuoteScreen> {
  File? _selectedImage;
  bool _hasError = false;
  String _errorMessage = '';

  // 从相册选择照片
  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      Navigator.pop(context, File(image.path));
    }
  }

  // 使用相机拍照
  Future<void> _takePhotoWithCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      Navigator.pop(context, File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择照片'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 提示文本
            const Text(
              '选择一张照片，让AI为你生成道家真言',
              style: AppTheme.subtitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),

            // 错误提示
            if (_hasError)
              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8.0),
                          Text('错误', style: AppTheme.subtitleStyle),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Text(_errorMessage, style: AppTheme.bodyStyle),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32.0),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text('选择照片'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _takePhotoWithCamera,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('拍照'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
