import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nfc_manager/nfc_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  InAppWebViewController? webViewController;
  bool loading = false;
  bool error = false;

  void _startNfc() {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          if (tag.data.containsKey('ndef')) {
            final ndef = tag.data['ndef'];

            if (ndef != null && ndef['cachedMessage'] != null) {
              final cachedMessage = ndef['cachedMessage'];

              if (cachedMessage['records'] != null) {
                for (var record in cachedMessage['records']) {
                  if (record['payload'] != null) {
                    Uint8List payload = record['payload'];

                    String decodedString =
                        utf8.decode(payload, allowMalformed: true);
                    String code = decodedString.substring(3);
                    _triggerWebviewAction(code);
                  }
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Error processing NFC tag: $e');
        }
      },
    );
  }

  void _triggerWebviewAction(String code) {
    webViewController?.evaluateJavascript(source: """
      if (window.onNfcCardScanned) {
        window.onNfcCardScanned('$code');
      } else {
        console.log('No handler for Flutter event.');
      }
    """);
  }

  @override
  void initState() {
    super.initState();
    _startNfc();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff110152),
      body: Stack(
        children: [
          SafeArea(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri.uri(
                  Uri.parse('https://web-pos.acoriss.com'),
                ),
              ),
              initialSettings: InAppWebViewSettings(
                userAgent: "Chrome/89.0",
              ),
              onLoadStart: (controller, uri) {
                loading = true;
                error = false;
                setState(() {});
              },
              onLoadStop: (controller, url) {
                loading = false;
                setState(() {});
              },
              onReceivedError: (controller, request, e) {
                webViewController = controller;
                loading = false;
                error = true;
                setState(() {});
              },
              onWebViewCreated: (InAppWebViewController controller) {
                webViewController = controller;
              },
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
            ),
          ),
          if (loading)
            Container(
              color: const Color(0xff110152),
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          if (error)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xff110152),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Oups!! Une erreur s'est produite, vérifiez votre connexion à internet et réessayez! 😥",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        webViewController?.reload();
                      },
                      child: const Text("Réessayer"),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
