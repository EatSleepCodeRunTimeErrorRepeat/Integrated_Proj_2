// lib/widgets/adsense_widget.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:html' as html;

class AdsenseWidget extends StatefulWidget {
  const AdsenseWidget({super.key});

  @override
  State<AdsenseWidget> createState() => _AdsenseWidgetState();
}

class _AdsenseWidgetState extends State<AdsenseWidget> {
  final html.IFrameElement _iFrameElement = html.IFrameElement();

  @override
  void initState() {
    super.initState();

    // The AdSense script now uses your Publisher ID.
    final script = html.ScriptElement()
      ..async = true
      ..src =
          'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-6693022899310808'
      ..crossOrigin = 'anonymous';

    // This is the ad unit slot. The 'InsElement' typo is now fixed.
    final ad = html.Element.tag('ins')
      ..className = 'adsbygoogle'
      ..style.display = 'block'
      ..setAttribute('data-ad-client', 'ca-pub-6693022899310808')
      ..setAttribute('data-ad-slot', '3720493789')
      ..setAttribute('data-ad-format', 'auto')
      ..setAttribute('data-full-width-responsive', 'true');

    // This script pushes the ad request.
    final pushScript = html.ScriptElement()
      ..text = '(adsbygoogle = window.adsbygoogle || []).push({});';

    // Configure the iFrame to be borderless.
    _iFrameElement
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none';

    // Append the necessary HTML elements to the iFrame body.
    _iFrameElement.srcdoc =
        '${script.outerHtml}${ad.outerHtml}${pushScript.outerHtml}';

    // Register the iFrame as a view that Flutter can display.
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'adsense-view',
      (int viewId) => _iFrameElement,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 90, // Set a fixed height for banner area
      width: double.infinity,
      child: HtmlElementView(viewType: 'adsense-view'),
    );
  }
}
