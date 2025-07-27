// screens/useradd_screen.dart
import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/useradd_style.dart';
import '../services/user_management_service.dart';

class UserAddScreen extends StatefulWidget {
  @override
  _UserAddScreenState createState() => _UserAddScreenState();
}

class _UserAddScreenState extends State<UserAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  String _selectedRole = 'Cashier';
  bool _isActive = true;
  bool _isLoading = false;

  final UserManagementService _userService = UserManagementService();

  final List<String> _roles = ['Admin', 'Manager', 'Cashier', 'Inventory'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF5F5F5),
        child: Row(
          children: [
            // Fix: Changed selectedItem to currentScreen
            AppSidebar(currentScreen: 'settings'),
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New User', style: UserAddStyles.headerStyle),
              const SizedBox(height: 30),
              _buildForm(),
              const SizedBox(height: 40),
              _buildRolePermissionsSection(),
              const SizedBox(height: 40),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextFormField('First Name', _nameController,
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the user\'s name';
                  }
                  return null;
                }),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTextFormField('Username', _usernameController,
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextFormField('Email Address', _emailController,
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                }),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTextFormField('Phone Number', _phoneController,
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextFormField('Password', _passwordController,
                    obscureText: true, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                }),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildDropdown(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value ?? false;
                  });
                },
              ),
              Text('Active User', style: UserAddStyles.labelStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'User Role',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      onChanged: (String? newValue) {
        setState(() {
          _selectedRole = newValue!;
        });
      },
      items: _roles.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildRolePermissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Role Permissions', style: UserAddStyles.sectionHeaderStyle),
        const SizedBox(height: 20),
        _buildPermissionsForRole(),
      ],
    );
  }

  Widget _buildPermissionsForRole() {
    Map<String, List<String>> permissions = {
      'Admin': ['Full Access to all features'],
      'Manager': [
        'Process Sales',
        'Process Refunds',
        'View Reports',
        'Manage Inventory',
        'View Settings'
      ],
      'Cashier': ['Process Sales', 'Process Refunds', 'View Receipt Screen'],
      'Inventory': ['View Inventory', 'Edit Inventory', 'Add Products'],
    };

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_selectedRole, style: UserAddStyles.roleTextStyle),
          const SizedBox(height: 10),
          ...permissions[_selectedRole]!.map((permission) => Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 5),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 10),
                    Text(permission, style: UserAddStyles.permissionTextStyle),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel', style: UserAddStyles.cancelButtonStyle),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _addUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF363753),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text('Add User', style: UserAddStyles.addButtonStyle),
        ),
      ],
    );
  }

  void _addUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _userService.addUser(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _nameController.text,
          phone: _phoneController.text,
          role: _selectedRole.toLowerCase(),
          username: _usernameController.text,
          isActive: _isActive,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User added successfully')),
        );

        // Reset form
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _passwordController.clear();
        _usernameController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding user: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
