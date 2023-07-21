import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:url_launcher/url_launcher.dart';

class JoinOfferWallScreen extends StatefulWidget {
  JoinOfferWallScreen({Key? key, this.data}) : super(key: key);
  dynamic data;

  @override
  State<JoinOfferWallScreen> createState() => _JoinOfferWallScreenState();
}

class _JoinOfferWallScreenState extends State<JoinOfferWallScreen> {
  InAppWebViewController? webView;

  String myUrl =
      'https://abee997.co.kr/stat/index.php/Login/get__post_register_test';

  List? _languages = [];

  ContextMenu? contextMenu;
  Future<void> _getPreferredLanguages() async {
    try {
      final languages = await Devicelocale.preferredLanguages;
      print((languages != null)
          ? languages
          : "unable to get preferred languages");
      setState(() => _languages = languages);
      print("_languages$_languages");
    } on PlatformException {
      print("Error obtaining preferred languages");
    }
  }

  @override
  void initState() {
    _getPreferredLanguages();
    // myUrl = widget.data['api'] ?? '';
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
            color: AppColor.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: InAppWebView(
            onWebViewCreated: (controller) {
              webView = controller;
              webView?.loadUrl(urlRequest: URLRequest(url: Uri.parse(myUrl)));
              print("change");
            },
            onLoadStart: (controller, url) {},
            // initialUrlRequest: URLRequest(url: Uri.parse(myurl)),
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var uri = navigationAction.request.url!;

              print("uriuriuriuri$uri");
              if (![
                "http",
                "https",
                "file",
                "chrome",
                "data",
                "javascript",
                "about"
              ].contains(uri.scheme)) {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(
                    uri,
                  );

                  return NavigationActionPolicy.CANCEL;
                }
              }

             

              return NavigationActionPolicy.ALLOW;
            },

            onLoadStop: (controller, url) async {
              print("loadStop${url}");
              var html = await webView?.evaluateJavascript(
                  source:
                      "window.document.getElementsByTagName('html')[0].outerHTML;");
              printWrapped("loadStopurl$html");

              controller.addJavaScriptHandler(
                  handlerName: "Toaster",
                  callback: (args) {
                    // Here you receive all the arguments from the JavaScript side
                    // that is a List<dynamic>
                    print("From the JavaScript side:");
                    print(args);
                    return args.reduce((curr, next) => curr + next);
                  });
              try {} catch (ex) {
                print("exex$ex");
              }
            },

            // ignore: prefer_collection_literals
            gestureRecognizers: Set()
              ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()
                ..onTap = () {
                  print("This one prints");
                })),

            onUpdateVisitedHistory: (controller, url, androidIsReload) async {},
            onConsoleMessage: (controller, consoleMessage) {
              controller.evaluateJavascript(source: '');
              printWrapped("consoleMessage$consoleMessage");
            },
          ))
        ],
      ),
    );
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}