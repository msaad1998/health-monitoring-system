// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddHardwareModule extends StatefulWidget {
  const AddHardwareModule({super.key});

  @override
  _AddHardwareModuleState createState() => _AddHardwareModuleState();
}

class _AddHardwareModuleState extends State<AddHardwareModule> {
  Future<List<DocumentSnapshot>> getAvailablePatients() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Patient')
        .where('hardwareId', isEqualTo: '')
        .get();
    return querySnapshot.docs;
  }

  Future<void> assignBedToPatient(
      DocumentSnapshot patient, DocumentSnapshot hardware) async {
    // Assign bed to the patient
    String patientId = patient.id;

    // Check if the patient document exists
    DocumentSnapshot<Map<String, dynamic>> patientDoc = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(patientId)
        .get();

    if (patientDoc.exists && patientDoc.data() != null) {
      // Update the patient's document with the bed ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(patientId)
          .update({'hardwareId': hardware.id});

      // Update the selected hardware's document
      await FirebaseFirestore.instance
          .collection('hardware')
          .doc(hardware.id)
          .update({'isAvailable': false});

      // Display a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Hardware allocated to patient successfully')),
      );
    } else {
      throw Exception('Patient document not found.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allocate Hardware'),
        backgroundColor: const Color.fromARGB(255, 184, 181, 182),
      ),
      backgroundColor: const Color.fromARGB(255, 184, 181, 182),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Hardware:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('hardware')
                    .where('isAvailable', isEqualTo: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  }
                  List<QueryDocumentSnapshot> hardwareList =
                      snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: hardwareList.length,
                    itemBuilder: (context, index) {
                      QueryDocumentSnapshot hardware = hardwareList[index];
                      return ListTile(
                        title: Text(hardware['hardwareName']),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            // Get available patients
                            List<DocumentSnapshot> availablePatients =
                                await getAvailablePatients();

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const ListTile(
                                        title: Text('Assign hardware'),
                                      ),
                                      const Divider(),
                                      if (availablePatients.isNotEmpty)
                                        ...availablePatients.map((patient) {
                                          return ListTile(
                                            title: Text(patient['name']),
                                            onTap: () async {
                                              Navigator.of(context).pop();
                                              await assignBedToPatient(
                                                  patient, hardware);
                                            },
                                          );
                                        }).toList()
                                      else
                                        const ListTile(
                                          title: Text('No available patients'),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text('Allocate'),
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
