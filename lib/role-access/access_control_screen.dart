import 'dart:math';
import 'package:flutter/material.dart';
import 'access_control_metadata.dart';
import 'access_control_sdk.dart';
import 'user_model.dart';
import 'document_model.dart';

class AccessControlScreen extends StatefulWidget {
  @override
  _AccessControlScreenState createState() => _AccessControlScreenState();
}

class _AccessControlScreenState extends State<AccessControlScreen> {
  final AccessControlSDK _accessControlSDK = AccessControlSDK();
  
  Document? _selectedDocument;
  User? _selectedUser;
  String _selectedPermission = 'view';
  
  List<AccessControlMetadata> _permissions = [];
  bool _isAssigning = false;

  final List<Document> _documents = getMockDocuments();
  final List<User> _users = getMockUsers();

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Access Control', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                    'Assign New Permission',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800],
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildDocumentDropdown(),
                  SizedBox(height: 16),
                  _buildUserDropdown(),
                  SizedBox(height: 16),
                  _buildPermissionDropdown(),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.security),
                      label: Text(
                        'Assign Permission',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: _isAssigning || _selectedDocument == null || _selectedUser == null
                          ? null
                          : _assignPermission,
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
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Text(
                'Assigned Permissions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[800],
                ),
              ),
            ),
            Expanded(
              child: _permissions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.security,
                            size: 64,
                            color: Colors.indigo.withOpacity(0.3),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No permissions assigned yet',
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
                      itemCount: _permissions.length,
                      itemBuilder: (context, index) {
                        final permission = _permissions[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Dismissible(
                            key: Key(permission.id),
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
                                    title: Text('Confirm Revoke'),
                                    content: Text('Are you sure you want to revoke this permission?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text('CANCEL'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: Text('REVOKE', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) {
                              _revokePermission(permission.id);
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getPermissionColor(permission.permissionLevel).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getPermissionIcon(permission.permissionLevel),
                                  color: _getPermissionColor(permission.permissionLevel),
                                  size: 32,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirm Revoke'),
                                        content: Text('Are you sure you want to revoke this permission?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: Text('CANCEL'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: Text('REVOKE', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  
                                  if (confirmed == true) {
                                    _revokePermission(permission.id);
                                  }
                                },
                              ),
                              title: Text(
                                permission.userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[800],
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(
                                          permission.permissionLevel.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        backgroundColor: _getPermissionColor(permission.permissionLevel),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        padding: EdgeInsets.zero,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Document: ${_getDocumentTitle(permission.documentId)}',
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Assigned on: ${_formatDate(permission.assignedDate)}',
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
    );
  }

  Widget _buildDocumentDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Document>(
          isExpanded: true,
          value: _selectedDocument,
          hint: Text('Select Document'),
          items: _documents.map((Document document) {
            return DropdownMenuItem<Document>(
              value: document,
              child: Text(document.title),
            );
          }).toList(),
          onChanged: (Document? newValue) {
            setState(() {
              _selectedDocument = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildUserDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<User>(
          isExpanded: true,
          value: _selectedUser,
          hint: Text('Select User'),
          items: _users.map((User user) {
            return DropdownMenuItem<User>(
              value: user,
              child: Text('${user.name} (${user.role})'),
            );
          }).toList(),
          onChanged: (User? newValue) {
            setState(() {
              _selectedUser = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPermissionDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedPermission,
          items: [
            DropdownMenuItem(value: 'view', child: Text('View')),
            DropdownMenuItem(value: 'edit', child: Text('Edit')),
            DropdownMenuItem(value: 'download', child: Text('Download')),
          ],
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedPermission = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Color _getPermissionColor(String permissionLevel) {
    switch (permissionLevel) {
      case 'view':
        return Colors.blue;
      case 'edit':
        return Colors.orange;
      case 'download':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPermissionIcon(String permissionLevel) {
    switch (permissionLevel) {
      case 'view':
        return Icons.visibility;
      case 'edit':
        return Icons.edit;
      case 'download':
        return Icons.download;
      default:
        return Icons.security;
    }
  }

  String _getDocumentTitle(String documentId) {
    final document = _documents.firstWhere(
      (doc) => doc.id == documentId,
      orElse: () => Document(
        id: 'unknown',
        title: 'Unknown Document',
        fileName: 'unknown.file',
        uploadDate: DateTime.now(),
      ),
    );
    return document.title;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _generateUniqueId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNumber = random.nextInt(10000);
    return '${timestamp}_$randomNumber';
  }

  Future<void> _loadPermissions() async {
    try {
      final permissions = await _accessControlSDK.getAllPermissions();
      setState(() {
        _permissions = permissions;
      });
    } catch (e) {
      print('Error loading permissions: $e');
    }
  }

  Future<void> _assignPermission() async {
    if (_selectedDocument == null || _selectedUser == null) return;

    setState(() {
      _isAssigning = true;
    });

    try {
      final metadata = AccessControlMetadata(
        id: _generateUniqueId(),
        documentId: _selectedDocument!.id,
        userId: _selectedUser!.id,
        userName: _selectedUser!.name,
        permissionLevel: _selectedPermission,
        assignedDate: DateTime.now(),
      );

      await _accessControlSDK.assignPermission(metadata);
      
      setState(() {
        _selectedDocument = null;
        _selectedUser = null;
        _selectedPermission = 'view';
        _isAssigning = false;
      });

      _loadPermissions();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission assigned successfully!')),
      );
    } catch (e) {
      setState(() {
        _isAssigning = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error assigning permission: $e')),
      );
    }
  }

  Future<void> _revokePermission(String permissionId) async {
    try {
      await _accessControlSDK.revokePermission(permissionId);
      
      setState(() {
        _permissions.removeWhere((permission) => permission.id == permissionId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission revoked successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error revoking permission: $e')),
      );
    }
  }
} 