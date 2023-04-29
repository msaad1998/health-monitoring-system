import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Update User Profile Demo',
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update User Profile'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Edit Profile'),
          onPressed: () async {
            // var updatedUserData = await Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => EditProfileScreen()),
            // );
            // await updateUserProfile(updatedUserData);
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text('Profile updated')),
            // );
          },
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    var currentUser = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: currentUser?.uid);
    _emailController = TextEditingController(text: currentUser?.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                var updatedUserData = {
                  'uid': _nameController.text.trim(),
                  'email': _emailController.text.trim(),
                };
                Navigator.pop(context, updatedUserData);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Update the current user's profile data in Firebase
Future<void> updateUserProfile(Map<String, dynamic> updatedUserData) async {
  try {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Update the user's profile data in Firebase
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .update(updatedUserData);

    // Refresh the user's data
    await currentUser?.reload();
  } catch (error) {
    print('Error updating user profile: $error');
  }
}
