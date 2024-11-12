// ignore_for_file: use_build_context_synchronously

import 'package:acorisspos/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool loading = false;

  void initialisePermissions() async {
    loading = true;
    setState(() {});
    PermissionStatus status = await Permission.camera.status;
    if (status.isGranted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (ctx) => const HomeScreen(),
        ),
        (route) => false,
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text("Donner accès à la caméra"),
            content: const Text(
              "Pour profiter des fonctionnalités de Acoriss POS, vous devez donner l'accès à votre caméra à l'application, celà va permettre à l'application de scanner les cartes ou tokens pour les paiements.",
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  PermissionStatus status = await Permission.camera.request();
                  if (status.isGranted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (ctx) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  } else {
                    loading = false;
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
                child: const Text("Autoriser"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initialisePermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff110152),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : const Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Attention!",
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    "Il semble que vous ayez bloqué l'accès à la caméra à l'application, vous ne pourrez pas donc profiter de toutes les fonctionnalités",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    "Rendez-vous dans les paramètres de votre téléphonne > applications > scaneex > autorisations > camera > autoriser",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
