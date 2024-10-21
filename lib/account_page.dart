import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // Text editing controllers to manage text input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // Form key to validate form fields
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill the fields with some assumed initial data
    _nameController.text = "John Doe";
    _emailController.text = "johndoe@email.com";
    _phoneController.text = "+1 123 456 7890";
    _usernameController.text = "johndriver";
  }

  @override
  void dispose() {
    // Dispose of the controllers when not needed to avoid memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: Colors.blue, // Blue theme for the app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Validate form before saving
              if (_formKey.currentState!.validate()) {
                _saveChanges();
              }
            },
          ),
        ],
      ),

      // Main body of the account page
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20), // Spacing between elements

              // Name field (using TextFormField)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email field (using TextFormField)
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone number field (using TextFormField)
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  } else if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Username field (using TextFormField)
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),

      // Floating Action Button for any action like editing info
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // You could use this for editing or another action
          _editInformation();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.edit),
      ),
    );
  }

  // Function to simulate saving the changes
  void _saveChanges() {
    String name = _nameController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;
    String username = _usernameController.text;

    // Simulate saving or showing a message
    print("Saving changes for $name, $email, $phone, $username");

    // Show a snackbar as a feedback for the save action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Changes saved for $name')),
    );
  }

  // Function to simulate editing information
  void _editInformation() {
    // For now, simply print the action (this can be extended as needed)
    print('Edit button pressed');
  }
}
