// 공통으로 사용할 Snack Bar와 Dialog 기능을 구현

import 'package:flutter/material.dart';

class Message{
  
  // Snack Bar
  void errorSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar( 
      SnackBar( 
        content: Text(message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onError
        ),), 
        duration: Duration(seconds: 1), 
        backgroundColor: Theme.of(context).colorScheme.error), 
        );
  }

   void successSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar( 
      SnackBar( 
        content: Text(message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary
        ),), 
        duration: Duration(seconds: 1), 
        backgroundColor: Theme.of(context).colorScheme.secondary), 
        );
  }

  // Dialog
  void showAlertPopup(BuildContext context, String message, List<Widget> widgets)
  {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          actions: widgets,
        );
      },
    );    
  }
}