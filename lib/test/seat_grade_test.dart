import 'package:flutter/material.dart';

class SeatGradeTest extends StatefulWidget {
  const SeatGradeTest({super.key});

  @override
  State<SeatGradeTest> createState() => _SeatGradeTestState();
}

class _SeatGradeTestState extends State<SeatGradeTest> {
  
  late int flag;

  Map<String, int> grademap = 
  (
    {"VIP":1,"S":2,"A":4}
  );

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('data'),
      ),
      body: Center(child:Column(
        children: [
          // Row(
          //   children: [
          //     Checkbox(value: , onChanged: (value) {
                
          //     },)
          //   ],
          // )
        ],
      ),),
    );
  } // build 



} // class
