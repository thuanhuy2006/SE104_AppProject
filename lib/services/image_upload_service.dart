import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_keys.dart';

class ImageUploadService {
  /// Upload một tệp hình ảnh cục bộ lên Cloudinary và trả về URL ảnh trực tuyến bảo mật (HTTPS).
  /// Sử dụng cơ chế Unsigned Upload của Cloudinary.
  /// Nếu upload thất bại, sẽ trả về null.
  static Future<String?> uploadImage(File file) async {
    try {
      if (cloudinaryCloudName.isEmpty || 
          cloudinaryCloudName == "YOUR_CLOUDINARY_CLOUD_NAME") {
        throw Exception("Chưa cấu hình Cloudinary Cloud Name trong lib/constants/api_keys.dart!");
      }
      if (cloudinaryUploadPreset.isEmpty ||
          cloudinaryUploadPreset == "YOUR_CLOUDINARY_UPLOAD_PRESET") {
        throw Exception("Chưa cấu hình Cloudinary Upload Preset trong lib/constants/api_keys.dart!");
      }

      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload");
      final request = http.MultipartRequest("POST", uri);
      
      // Cloudinary yêu cầu tham số 'upload_preset' đối với Unsigned Upload
      request.fields['upload_preset'] = cloudinaryUploadPreset;
      
      // Thêm tệp ảnh vào request với tên field là 'file'
      final multipartFile = await http.MultipartFile.fromPath('file', file.path);
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final String? secureUrl = jsonResponse['secure_url'];
        if (secureUrl != null) {
          debugPrint("Upload ảnh lên Cloudinary thành công: $secureUrl");
          return secureUrl;
        }
      }
      
      final errorBody = response.body;
      debugPrint("Upload ảnh lên Cloudinary thất bại. Status: ${response.statusCode}, Body: $errorBody");
      
      String detailedMsg = "HTTP ${response.statusCode}";
      try {
        final parsed = jsonDecode(errorBody);
        if (parsed is Map && parsed['error'] != null && parsed['error']['message'] != null) {
          detailedMsg = parsed['error']['message'];
        }
      } catch (_) {}
      
      throw Exception("Cloudinary: $detailedMsg");
    } catch (e) {
      debugPrint("Đã xảy ra lỗi khi upload ảnh lên Cloudinary: $e");
      rethrow;
    }
  }
}
