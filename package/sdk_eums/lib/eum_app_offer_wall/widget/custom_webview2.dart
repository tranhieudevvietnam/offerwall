import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/gen/assets.gen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../utils/appStyle.dart';

class CustomWebView2 extends StatefulWidget {
  final dynamic urlLink;
  final dynamic title;
  final Function()? onSave;
  final Function()? mission;
  final Function onClose;
  final bool showMission;
  final Color color;
  final Color colorIconBack;
  final Widget? actions;
  final showImage;
  const CustomWebView2(
      {Key? key,
      this.urlLink,
      this.title,
      this.onSave,
      this.mission,
      required this.onClose,
      this.showMission = false,
      this.colorIconBack = AppColor.black,
      this.color = AppColor.white,
      this.actions,
      this.showImage = false})
      : super(key: key);

  @override
  State<CustomWebView2> createState() => _CustomWebView2State();
}

class _CustomWebView2State extends State<CustomWebView2> {
  late final WebViewController _controller;
  bool isLoading = true;

  Timer? _timer;
  int _start = 5;
  bool showButton = false;

  String getProperHtml(String content) {
    String start1 = 'https:';
    int startIndex1 = content.indexOf(start1);
    String iframeTag1 = content.substring(startIndex1 + 6);
    content = iframeTag1.replaceAll("$iframeTag1", "http:${iframeTag1}");
    return content;
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
          if (_start == 0) {
            setState(() {
              showButton = true;
            });
          }
        }
      },
    );
  }

  double deviceWith = 0;
  getDeviceWidth() async {
    deviceWith = double.parse(await LocalStoreService().getDeviceWidth());
    print('deviceWithdeviceWith $deviceWith');
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.showMission) {
      startTimer();
    }
    super.initState();

    getDeviceWidth();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    controller
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onUrlChange: (change) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith((widget.urlLink))) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(getProperHtml(widget.urlLink ?? '')));
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = controller;
  }

  @override
  void dispose() {
    _timer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 70),
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          // title:
          //     Text(widget.title, style: AppStyle.bold.copyWith(fontSize: 16)),
          // centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              widget.onClose();
            },
            child: Container(
                padding: EdgeInsets.all(16),
                child: Icon(Icons.arrow_back, color: Colors.black, size: 24)),
          ),
          actions: [widget.actions ?? const SizedBox()],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  CachedNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      imageUrl: widget.urlLink,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) {
                        return Image.asset(Assets.logo.path,
                            package: "sdk_eums", height: 16);
                      }),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 70,
                  )
                ],
              ),
            ),
            !widget.showMission
                ? const SizedBox()
                : Positioned(
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).padding.bottom + 20),
                      width: deviceWith > 0
                          ? deviceWith
                          : MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                              onTap: widget.onSave,
                              child: Image.asset(Assets.bookmark.path,
                                  package: "sdk_eums",
                                  height: 27,
                                  color: AppColor.black)),
                          GestureDetector(
                            onTap: !showButton ? null : widget.mission,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: !showButton
                                      ? AppColor.grey.withOpacity(0.5)
                                      : AppColor.red),
                              child: Text(
                                '포인트 적립하기',
                                style: AppStyle.medium.copyWith(
                                    color: !showButton
                                        ? AppColor.grey
                                        : AppColor.white),
                              ),
                            ),
                          ),
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: AppColor.grey.withOpacity(0.5),
                                  shape: BoxShape.circle),
                              child: Text(
                                _start.toString(),
                                style: AppStyle.medium.copyWith(fontSize: 16),
                              ))
                        ],
                      ),
                    ))
          ],
        ),
      ),
    );
  }
}
