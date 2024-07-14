import 'package:maring/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:maring/utils/color.dart';

class Commonpage extends StatefulWidget {
  final String url, title;
  const Commonpage({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<Commonpage> createState() => CommonpageState();
}

class CommonpageState extends State<Commonpage> {
  final GlobalKey webViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils().otherPageAppBar(context, widget.title, false),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
            ),
          ),
        ],
      ),
    );
  }
}
