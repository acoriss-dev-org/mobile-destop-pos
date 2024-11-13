import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  InAppWebViewController? webViewController;
  bool loading = false;
  bool error = false;

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
                  Uri.parse('https://kimia-monorepo.vercel.app'),
                ),
              ),
              initialSettings: InAppWebViewSettings(),
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
              child: const Center(
                child: Text(
                  "Oups!! Une erreur s'est produite, vérifiez votre connexion à internet et réessayez! 😥",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
        ],
      ),
    );
  }
}
