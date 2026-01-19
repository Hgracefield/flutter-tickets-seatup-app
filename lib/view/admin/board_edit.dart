import 'package:flutter/material.dart';
import 'package:seatup_app/util/global_data.dart';

class BoardEdit extends StatefulWidget {
  const BoardEdit({super.key});

  @override
  State<BoardEdit> createState() => _BoardEditState();
}

class _BoardEditState extends State<BoardEdit> {
  // === Property ===
  String imageUrl = "${GlobalData.url}/images/viewOne";
  String stockSelectAllUrl = "${GlobalData.url}/stock/selectAll";
  List<int> _imageList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  } // build
} // class
