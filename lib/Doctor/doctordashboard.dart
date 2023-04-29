// ignore_for_file: sort_child_properties_last, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_monitoring_system/Doctor/changedoctorpass.dart';
import 'package:health_monitoring_system/Doctor/doctorreading.dart';
import 'package:health_monitoring_system/Doctor/updatedoctor.dart';
import 'package:health_monitoring_system/Welcome/mainscreen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(242, 240, 234, 236),
        body: SafeArea(
          child: Column(children: [
            Container(
              color: const Color.fromARGB(255, 184, 181, 182),
              child: Row(children: [
                PopupMenuButton(
                  icon: const Icon(Icons.menu_rounded),
                  color: const Color.fromARGB(255, 59, 58, 58),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: TextButton(
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateDoctor(),
                                ));
                          });
                        },
                        child: const Text(
                          'Update Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      child: TextButton(
                        child: const Text(
                          'Change password',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DoctorPass()));
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: TextButton(
                        child: const Text(
                          'Change Email',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DocReading()));
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: TextButton(
                        onPressed: () {
                          logout(context);
                        },
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 218,
                ),
                const Text(
                  'Doctor',
                  style: TextStyle(
                      color: Color(0xff4c505b),
                      fontSize: 30,
                      fontWeight: FontWeight.w700),
                ),
                // const SizedBox(
                //   width: 35,
                // ),
              ]),
            ),
            const SizedBox(
              height: 60,
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    const CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(),
      ),
    );
  }
}
