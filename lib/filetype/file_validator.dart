class FileValidator {
  static const Map<String, List<String>> _supportedTypes = {
    'documents': ['pdf', 'doc', 'docx', 'txt', 'rtf'],
    'images': ['jpg', 'jpeg', 'png', 'gif', 'bmp'],
    'spreadsheets': ['xls', 'xlsx', 'csv'],
    'presentations': ['ppt', 'pptx'],
    'archives': ['zip', 'rar', '7z', 'tar', 'gz'],
    'audio': ['mp3', 'wav', 'ogg', 'flac'],
    'video': ['mp4', 'avi', 'mov', 'wmv', 'mkv'],
  };

  static const Map<String, int> _maxSizeInMB = {
    'documents': 10,
    'images': 5,
    'spreadsheets': 10,
    'presentations': 15,
    'archives': 50,
    'audio': 20,
    'video': 100,
  };

  static String? validateFileType(String fileName, List<String> allowedTypes) {
    final fileExtension = fileName.split('.').last.toLowerCase();
    if (!allowedTypes.contains(fileExtension)) {
      return 'File type .$fileExtension is not supported. Allowed types: ${allowedTypes.map((e) => '.$e').join(', ')}';
    }
    return null;
  }

  static String? validateFileSize(int sizeInBytes, int maxSizeInMB) {
    final sizeInMB = sizeInBytes / (1024 * 1024);
    if (sizeInMB > maxSizeInMB) {
      return 'File size (${sizeInMB.toStringAsFixed(1)} MB) exceeds maximum allowed size of $maxSizeInMB MB';
    }
    return null;
  }

  static Map<String, List<String>> get supportedTypes => _supportedTypes;
  static Map<String, int> get maxSizeInMB => _maxSizeInMB;

  static List<String> getAllowedFileExtensions(List<String> categories) {
    final allowedExtensions = <String>[];
    for (final category in categories) {
      if (_supportedTypes.containsKey(category)) {
        allowedExtensions.addAll(_supportedTypes[category]!);
      }
    }
    return allowedExtensions;
  }

  static int getMaxSizeForCategories(List<String> categories) {
    int maxSize = 0;
    for (final category in categories) {
      if (_maxSizeInMB.containsKey(category)) {
        final categorySize = _maxSizeInMB[category]!;
        if (categorySize > maxSize) {
          maxSize = categorySize;
        }
      }
    }
    return maxSize;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
} 