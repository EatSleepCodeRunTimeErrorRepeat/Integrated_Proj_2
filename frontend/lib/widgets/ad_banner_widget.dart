// lib/widgets/ad_banner_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // Use the test ad unit ID provided by Google.
  // This is crucial to avoid getting your account suspended during testing.
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  // We use didChangeDependencies because it can safely access context.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  /// Loads a banner ad and sets the state when it's ready.
  void _loadAd() async {
    // Prevent reloading if an ad is already loaded
    if (_bannerAd != null && _isLoaded) {
      return;
    }

    // Get the adaptive ad size.
    // This is the best practice from the official documentation.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      debugPrint('Unable to get ad size.');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  /// Displays the ad widget if it's loaded.
  @override
  Widget build(BuildContext context) {
    // Only build the AdWidget if the ad is loaded and not null
    if (_bannerAd != null && _isLoaded) {
      return SafeArea(
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    } else {
      // If the ad is not loaded, return an empty container.
      return const SizedBox.shrink();
    }
  }

  // Always dispose of ads when the widget is removed from the tree.
  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
