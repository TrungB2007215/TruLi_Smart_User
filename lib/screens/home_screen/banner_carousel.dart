import 'dart:async';
import 'package:flutter/material.dart';

class BannerCarousel extends StatefulWidget {
  @override
  _BannerCarouselState createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentIndex = 0;
  late Timer _timer;
  final List<String> _imagePaths = [
    'assets/banner/asus.jpg',
    'assets/banner/acer.jpg',
    'assets/banner/dell.jpg',
    'assets/banner/macbook.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _imagePaths.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Image.asset(
        _imagePaths[_currentIndex],
        fit: BoxFit.cover,
      ),
    );
  }
}