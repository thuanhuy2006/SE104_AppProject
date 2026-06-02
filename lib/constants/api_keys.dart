// Cấu hình Cloudinary (Dành cho việc lưu trữ hình ảnh sản phẩm)
// Bạn cần đăng ký tài khoản tại https://cloudinary.com/
// Các giá trị này được tải động thông qua tham số --dart-define-from-file=.env khi chạy/build ứng dụng.

const String cloudinaryCloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
const String cloudinaryUploadPreset = String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET');
