import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignedBedsPage extends StatefulWidget {
  @override
  _AssignedBedsPageState createState() => _AssignedBedsPageState();
}

class _AssignedBedsPageState extends State<AssignedBedsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assigned Beds'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assigned Patients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('bedId', isNotEqualTo: '')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  }
                  List<QueryDocumentSnapshot> patientList = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: patientList.length,
                    itemBuilder: (context, index) {
                      QueryDocumentSnapshot patient = patientList[index];
                      return ListTile(
                        title: Text(patient['name']),
                        subtitle: Text('Bed ID: ${patient['bedId']}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Deallocate Bed'),
                                  content: Text(
                                      'Are you sure you want to deallocate the bed from ${patient['name']}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        // Deallocate bed from the patient
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(patient.id)
                                            .update({'bedId': ''});

                                        // Update the bed document
                                        String bedId = patient['bedId'];
                                        await FirebaseFirestore.instance
                                            .collection('bed')
                                            .doc(bedId)
                                            .update({'isAvailable': true});

                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Deallocate'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Deallocate'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
