import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'file_validator.dart';

class FileValidationScreen extends StatefulWidget {
  @override
  _FileValidationScreenState createState() => _FileValidationScreenState();
}

class _FileValidationScreenState extends State<FileValidationScreen> {
  File? _selectedFile;
  bool _isValidating = false;
  String? _validationResult;
  bool _isValid = false;
  
  final Map<String, bool> _selectedCategories = {
    'documents': true,
    'images': false,
    'spreadsheets': false,
    'presentations': false,
    'archives': false,
    'audio': false,
    'video': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Type Validation', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select File Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: FileValidator.supportedTypes.keys.map((category) {
                        return FilterChip(
                          label: Text(category.toUpperCase()),
                          selected: _selectedCategories[category] ?? false,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategories[category] = selected;
                              _validationResult = null;
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.indigo.withOpacity(0.2),
                          checkmarkColor: Colors.indigo,
                          labelStyle: TextStyle(
                            color: _selectedCategories[category] ?? false
                                ? Colors.indigo[800]
                                : Colors.grey[700],
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Pick a File to Validate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: _pickFile,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.indigo.withOpacity(0.05),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.file_present,
                                size: 40,
                                color: Colors.indigo,
                              ),
                              SizedBox(height: 10),
                              Text(
                                _selectedFile == null
                                    ? 'Click to select a file'
                                    : '${_selectedFile!.path.split('/').last} (${FileValidator.formatFileSize(_selectedFile!.lengthSync())})',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedFile == null
                                      ? Colors.grey[700]
                                      : Colors.indigo[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.check_circle_outline),
                        label: Text(
                          'Validate File',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: _selectedFile == null || _isValidating || 
                                   !_selectedCategories.values.contains(true)
                            ? null
                            : _validateFile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_validationResult != null)
                Container(
                  margin: EdgeInsets.only(top: 16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _isValid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isValid ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isValid ? Icons.check_circle : Icons.error,
                            color: _isValid ? Colors.green : Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            _isValid ? 'File Validation Successful' : 'File Validation Failed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isValid ? Colors.green[800] : Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        _validationResult!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supported File Types',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    ...FileValidator.supportedTypes.entries.map((entry) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Types: ${entry.value.map((e) => '.$e').join(', ')}',
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                            Text(
                              'Max Size: ${FileValidator.maxSizeInMB[entry.key]} MB',
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    List<String> allowedExtensions = [];
    for (final entry in _selectedCategories.entries) {
      if (entry.value) {
        allowedExtensions.addAll(FileValidator.supportedTypes[entry.key]!);
      }
    }

    if (allowedExtensions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one file category')),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _validationResult = null;
      });
    }
  }

  void _validateFile() {
    if (_selectedFile == null) return;

    setState(() {
      _isValidating = true;
    });

    List<String> selectedCategoryNames = [];
    for (final entry in _selectedCategories.entries) {
      if (entry.value) {
        selectedCategoryNames.add(entry.key);
      }
    }

    final allowedExtensions = FileValidator.getAllowedFileExtensions(selectedCategoryNames);
    final maxSizeInMB = FileValidator.getMaxSizeForCategories(selectedCategoryNames);
    
    final fileName = _selectedFile!.path.split('/').last;
    final fileSize = _selectedFile!.lengthSync();

    // Validate file type
    final typeValidation = FileValidator.validateFileType(fileName, allowedExtensions);
    if (typeValidation != null) {
      setState(() {
        _validationResult = typeValidation;
        _isValid = false;
        _isValidating = false;
      });
      return;
    }

    // Validate file size
    final sizeValidation = FileValidator.validateFileSize(fileSize, maxSizeInMB);
    if (sizeValidation != null) {
      setState(() {
        _validationResult = sizeValidation;
        _isValid = false;
        _isValidating = false;
      });
      return;
    }

    // If we get here, the file is valid
    setState(() {
      _validationResult = 'File "${fileName}" (${FileValidator.formatFileSize(fileSize)}) is valid and meets all requirements.';
      _isValid = true;
      _isValidating = false;
    });
  }
} 