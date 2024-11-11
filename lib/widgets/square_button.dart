import 'package:flutter/material.dart';

Widget button(VoidCallback onPressed, String text) {
  return Container(padding: const EdgeInsets.all(3), height: 52, width: 172, child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(2),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      )));
}

Widget squareButton(VoidCallback onPressed, String text) {
  return Container(padding: const EdgeInsets.all(3), height: 72, width: 72, child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(2),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      )));
}

Widget squareImageButton(VoidCallback onPressed, String assetPath, {double height = 50}) {
  return Container(padding: const EdgeInsets.all(0), height: height, width: height, child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(3),
      ),
      child:  Image.asset(assetPath)));
}

Widget smallSquareImageButton(VoidCallback onPressed, String assetPath) {
  return Container(padding: const EdgeInsets.all(3), height: 36, width: 36, child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(2),
      ),
      child:  Image.asset(assetPath)));
}
