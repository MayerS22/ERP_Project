import 'dart:math';
import 'package:flutter/material.dart';
import 'document_metadata.dart';
import 'tagging_sdk.dart';

class TaggingScreen extends StatefulWidget {
  @override
  _TaggingScreenState createState() => _TaggingScreenState();
}

class _TaggingScreenState extends State<TaggingScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  
  bool _isProcessing = false;
  List<DocumentMetadata> _documents = [];
  DocumentMetadata? _selectedDocument;
  List<String> _suggestedTags = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _loadTags();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Tagging', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.indigo.withOpacity(0.1), Colors.white],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.all(16),
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
                      _selectedDocument == null ? 'Create New Document' : 'Edit Document',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Document Title',
                        labelStyle: TextStyle(color: Colors.indigo),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        labelStyle: TextStyle(color: Colors.indigo),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _tagsController,
                      decoration: InputDecoration(
                        labelText: 'Tags (comma separated)',
                        labelStyle: TextStyle(color: Colors.indigo),
                        hintText: 'e.g., important, report, finance',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    if (_suggestedTags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _suggestedTags.map((tag) => GestureDetector(
                          onTap: () => _addTag(tag),
                          child: Chip(
                            label: Text(tag),
                            backgroundColor: Colors.indigo.withOpacity(0.1),
                            labelStyle: TextStyle(color: Colors.indigo),
                          ),
                        )).toList(),
                      ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              icon: Icon(_selectedDocument == null ? Icons.add : Icons.save),
                              label: Text(
                                _selectedDocument == null ? 'Create Document' : 'Update Document',
                                style: TextStyle(fontSize: 16),
                              ),
                              onPressed: _isProcessing ? null : _saveDocument,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedDocument == null ? Colors.indigo : Colors.green[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_selectedDocument != null) ...[
                          SizedBox(width: 12),
                          SizedBox(
                            height: 50,
                            child: TextButton.icon(
                              icon: Icon(Icons.cancel, color: Colors.grey[700]),
                              label: Text('Cancel'),
                              onPressed: _isProcessing ? null : _clearForm,
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Tagged Documents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                  ),
                ),
              ),
              Container(
                height: 300, // Fixed height to prevent overflow
                padding: EdgeInsets.only(bottom: 20),
                child: _documents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64,
                              color: Colors.indigo.withOpacity(0.3),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No tagged documents yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _documents.length,
                        itemBuilder: (context, index) {
                          final document = _documents[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Dismissible(
                              key: Key(document.id),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red[400],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirm Delete'),
                                      content: Text('Are you sure you want to delete this document?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text('CANCEL'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: Text('DELETE', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              onDismissed: (direction) {
                                _deleteDocument(document.id);
                              },
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.article,
                                    color: Colors.indigo,
                                    size: 32,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.indigo),
                                      onPressed: () => _editDocument(document),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                                      onPressed: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Confirm Delete'),
                                              content: Text('Are you sure you want to delete this document?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: Text('CANCEL'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: Text('DELETE', style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        
                                        if (confirmed == true) {
                                          _deleteDocument(document.id);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                title: Text(
                                  document.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo[800],
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (document.description.isNotEmpty) ...[
                                      SizedBox(height: 4),
                                      Text(document.description),
                                    ],
                                    SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: document.tags.map((tag) => Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.indigo.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          tag,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.indigo[700],
                                          ),
                                        ),
                                      )).toList(),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _formatDate(document.lastUpdated),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _addTag(String tag) {
    final currentTags = _tagsController.text.isEmpty 
        ? [] 
        : _tagsController.text.split(',').map((e) => e.trim()).toList();
    
    if (!currentTags.contains(tag)) {
      final newTags = [...currentTags, tag];
      _tagsController.text = newTags.join(', ');
    }
  }

  Future<void> _saveDocument() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a document title')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final taggingSDK = TaggingSDK();
      final tags = _tagsController.text.isEmpty 
          ? <String>[] 
          : _tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
      
      if (_selectedDocument == null) {
        // Create new document
        final newDocument = DocumentMetadata(
          id: _generateUniqueId(),
          title: _titleController.text,
          description: _descriptionController.text,
          tags: tags,
          creationDate: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        await taggingSDK.createDocument(newDocument);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document created successfully!')),
        );
      } else {
        // Update existing document
        final updatedDocument = _selectedDocument!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          tags: tags,
          lastUpdated: DateTime.now(),
        );

        await taggingSDK.updateDocument(updatedDocument);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document updated successfully!')),
        );
      }
      
      _clearForm();
      _loadDocuments();
      _loadTags();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _clearForm() {
    setState(() {
      _selectedDocument = null;
      _titleController.clear();
      _descriptionController.clear();
      _tagsController.clear();
    });
  }

  void _editDocument(DocumentMetadata document) {
    setState(() {
      _selectedDocument = document;
      _titleController.text = document.title;
      _descriptionController.text = document.description;
      _tagsController.text = document.tags.join(', ');
    });
  }

  Future<void> _loadDocuments() async {
    try {
      final taggingSDK = TaggingSDK();
      final documents = await taggingSDK.getAllDocuments();
      setState(() {
        _documents = documents;
      });
    } catch (e) {
      print('Error loading documents: $e');
    }
  }

  Future<void> _loadTags() async {
    try {
      final taggingSDK = TaggingSDK();
      final tags = await taggingSDK.getAllTags();
      setState(() {
        _suggestedTags = tags;
      });
    } catch (e) {
      print('Error loading tags: $e');
    }
  }

  Future<void> _deleteDocument(String documentId) async {
    try {
      final taggingSDK = TaggingSDK();
      await taggingSDK.deleteDocument(documentId);
      
      // Clear form if the deleted document was selected
      if (_selectedDocument?.id == documentId) {
        _clearForm();
      }
      
      _loadDocuments();
      _loadTags();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting document: $e')),
      );
    }
  }

  String _generateUniqueId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNumber = random.nextInt(10000);
    return '${timestamp}_$randomNumber';
  }
} 