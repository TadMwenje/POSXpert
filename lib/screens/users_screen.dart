// screens/users_screen.dart
import 'package:flutter/material.dart';
import '../widgets/users_style.dart';
import '../services/user_management_service.dart';
import 'useradd_screen.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserManagementService _userService = UserManagementService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> users = await _userService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('User Management', style: UsersStyles.sectionHeaderStyle),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserAddScreen()),
                  ).then((_) => _loadUsers()); // Refresh after returning
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text('Add New User', style: UsersStyles.addButtonStyle),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF363753),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _buildUsersTable(),
          const SizedBox(height: 40),
          _buildPermissionsSection(),
        ],
      ),
    );
  }

  Widget _buildUsersTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Name', style: UsersStyles.tableHeaderStyle)),
                Expanded(
                    flex: 2,
                    child: Text('Email', style: UsersStyles.tableHeaderStyle)),
                Expanded(
                    flex: 1,
                    child: Text('Role', style: UsersStyles.tableHeaderStyle)),
                Expanded(
                    flex: 1,
                    child: Text('Status', style: UsersStyles.tableHeaderStyle)),
                Expanded(
                    flex: 2,
                    child:
                        Text('Actions', style: UsersStyles.tableHeaderStyle)),
              ],
            ),
          ),
          _users.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: Text('No users found')),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(user['f_name'] ?? 'Unknown',
                                  style: UsersStyles.tableValueStyle),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(user['email'] ?? 'No email',
                                  style: UsersStyles.tableValueStyle),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                _capitalizeFirst(user['role'] ?? 'Unknown'),
                                style: UsersStyles.tableValueStyle,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                _capitalizeFirst(user['state'] ?? 'unknown'),
                                style: user['state'] == 'active'
                                    ? UsersStyles.statusActiveStyle
                                    : UsersStyles.statusInactiveStyle,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      _showEditUserDialog(user);
                                    },
                                    tooltip: 'Edit user',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.key, color: Colors.orange),
                                    onPressed: () {
                                      _showResetPasswordDialog(user);
                                    },
                                    tooltip: 'Reset password',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      user['state'] == 'active'
                                          ? Icons.toggle_on
                                          : Icons.toggle_off,
                                      color: user['state'] == 'active'
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      _toggleUserStatus(user);
                                    },
                                    tooltip: user['state'] == 'active'
                                        ? 'Deactivate user'
                                        : 'Activate user',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(user);
                                    },
                                    tooltip: 'Delete user',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    // Implement edit user dialog
    // This could navigate to a separate edit screen or show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User'),
        content: Text('Edit user functionality to be implemented.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(Map<String, dynamic> user) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter new password for ${user['f_name']}'),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password cannot be empty')),
                );
                return;
              }

              try {
                await _userService.resetUserPassword(
                    user['id'], passwordController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password reset successfully')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Error resetting password: ${e.toString()}')),
                );
              }
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) async {
    final bool newStatus = user['state'] != 'active';

    try {
      await _userService.updateUserStatus(user['id'], newStatus);
      _loadUsers(); // Refresh user list

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User status updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user status: ${e.toString()}')),
      );
    }
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text(
            'Are you sure you want to delete ${user['f_name']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _userService.deleteUser(user['id']);
                Navigator.pop(context);
                _loadUsers(); // Refresh user list

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User deleted successfully')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error deleting user: ${e.toString()}')),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _buildPermissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Role Permissions', style: UsersStyles.sectionHeaderStyle),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRolePermissionRow(
                  'Admin', 'Full access to all system features and settings'),
              _buildRolePermissionRow('Manager',
                  'Access to sales, inventory, and reports. Limited settings access'),
              _buildRolePermissionRow('Cashier',
                  'Access to sales functions and basic inventory lookup'),
              _buildRolePermissionRow(
                  'Inventory', 'Access to inventory management features'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRolePermissionRow(String role, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: role == 'Admin'
                  ? Colors.blue
                  : role == 'Manager'
                      ? Colors.green
                      : role == 'Cashier'
                          ? Colors.orange
                          : Colors.purple,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              description,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
