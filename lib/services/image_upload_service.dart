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
          cloudinaryCloudName == "YOUR_CLOUDINARY_CLOUD_NAME" ||
          cloudinaryUploadPreset.isEmpty ||
          cloudinaryUploadPreset == "YOUR_CLOUDINARY_UPLOAD_PRESET") {
        debugPrint("Lỗi: Chưa cấu hình Cloudinary Cloud Name hoặc Upload Preset trong lib/constants/api_keys.dart!");
        return null;
      }

      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload");
      final request = http.MultipartRequest("POST", uri);
      
      // Cloudinary yêu cầu tham số 'upload_preset' đối với Unsigned Upload
      request.fields['upload_preset'] = cloudinaryUploadPreset;
      
      // Thêm tệp ảnh vào request với tên field là 'file'
      final multipartFile = await http.MultipartFile.fromPath('file', file.path);
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final String? secureUrl = jsonResponse['secure_url'];
        if (secureUrl != null) {
          debugPrint("Upload ảnh lên Cloudinary thành công: $secureUrl");
          return secureUrl;
        }
      }
      
      debugPrint("Upload ảnh lên Cloudinary thất bại. Status: ${response.statusCode}, Body: ${response.body}");
      return null;
    } catch (e) {
      debugPrint("Đã xảy ra lỗi khi upload ảnh lên Cloudinary: $e");
      return null;
    }
  }
}
