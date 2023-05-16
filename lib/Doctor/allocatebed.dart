import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllocateBedPage extends StatefulWidget {
  @override
  _AllocateBedPageState createState() => _AllocateBedPageState();
}

class _AllocateBedPageState extends State<AllocateBedPage> {
  Future<List<DocumentSnapshot>> getAvailablePatients() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Patient')
        .get();
    return querySnapshot.docs;
  }

  Future<void> assignBedToPatient(DocumentSnapshot patient) async {
    // Get the logged-in user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Check if the user is a doctor
      DocumentSnapshot<Map<String, dynamic>> doctorSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doctorSnapshot.exists &&
          doctorSnapshot.data() != null &&
          doctorSnapshot.data()!['role'] == 'Doctor') {
        // Get the available bed
        QuerySnapshot bedSnapshot = await FirebaseFirestore.instance
            .collection('bed')
            .where('isAvailable', isEqualTo: true)
            .limit(1)
            .get();

        if (bedSnapshot.docs.isNotEmpty) {
          DocumentSnapshot bed = bedSnapshot.docs.first;

          // Assign bed to the patient
          String patientId = patient.id;

          // Check if the patient document exists
          DocumentSnapshot<Map<String, dynamic>> patientDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(patientId)
                  .get();

          if (patientDoc.exists && patientDoc.data() != null) {
            // Update the patient's document with the bed ID
            await FirebaseFirestore.instance
                .collection('users')
                .doc(patientId)
                .update({'bedId': bed['uid']});

            // Update the selected bed's document
            await FirebaseFirestore.instance
                .collection('bed')
                .doc(bed.id)
                .update({'isAvailable': false});

            // Display a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Bed allocated to patient successfully')),
            );
          } else {
            throw Exception('Patient document not found.');
          }
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('No Beds Available'),
                content: Text(
                    'There are no beds available to assign to the patient.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        throw Exception('Only doctors can allocate beds.');
      }
    } else {
      throw Exception('User not logged in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Allocate Bed'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Patients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: getAvailablePatients(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  }
                  List<DocumentSnapshot> patientList = snapshot.data!;
                  return ListView.builder(
                    itemCount: patientList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot patient = patientList[index];
                      return ListTile(
                        title: Text(patient['name']),
                        trailing: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Assign Bed'),
                                  content: Text(
                                      'Are you sure you want to assign a bed to ${patient['name']}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        assignBedToPatient(patient);
                                      },
                                      child: Text('Assign'),
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
                          child: Text('Allocate'),
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
