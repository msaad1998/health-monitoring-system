// ignore_for_file: use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_monitoring_system/Admin/admindashboard.dart';

class HardwareModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(242, 240, 234, 236),
        appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 184, 181, 182),
            leading: BackButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminDashboard(),
                      ));
                });
              },
            )),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'Patient')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<DocumentSnapshot> documents = snapshot.data!.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic> data =
                    documents[index].data()! as Map<String, dynamic>;
                final String title = data['name'];
                final String subtitle = data['role'];
                final bool isToggled = data['isToggled'] ?? false;

                return ListTile(
                  title: Text(title),
                  subtitle: Text(subtitle),
                  trailing: Switch(
                    activeColor: Colors.deepPurpleAccent,
                    value: isToggled,
                    onChanged: (value) {
                      // Update the document in Firestore with the new state
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(documents[index].id)
                          .update({
                        'isToggled': value,
                      });
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
