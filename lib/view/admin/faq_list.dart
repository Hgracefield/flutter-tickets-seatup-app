import 'package:flutter/material.dart';

class FaqList extends StatefulWidget {
  const FaqList({super.key});

  @override
  State<FaqList> createState() => _FaqListState();
}

class _FaqListState extends State<FaqList> {
  // property

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('title')),
      body: Center(
        child: ListView.builder(
          itemCount: 10, // 결정<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
          itemBuilder: (context, index) {
            return Card(
              child: SizedBox(
                height: 50,
                child: Row(children: [Text('title'), Text('content'), Text('date')]),
              ),
            );
          },
        ),
      ),
    );
  } // build
} // class
