import 'package:flutter/material.dart';

class ResizableImage extends StatefulWidget {
  final String imgPath;
  const ResizableImage({Key? key, required this.imgPath}) : super(key: key);

  @override
  State<ResizableImage> createState() => _ResizableImageState();
}

class _ResizableImageState extends State<ResizableImage> {
  double sizeCoef = 2.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          sizeCoef = sizeCoef >= 8 ? 1 : sizeCoef * 2;
        });
      }, // Image tapped
      child:
          Image.asset('assets/images/${widget.imgPath}.png', scale: sizeCoef),
    );
  }
}
