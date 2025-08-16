import 'package:daiki_axis_stp/Core/Utils/colors.dart';
import 'package:flutter/material.dart';

class InspectorNotification extends StatefulWidget {
  const InspectorNotification({super.key});

  @override
  State<InspectorNotification> createState() => _InspectorNotificationState();
}

class _InspectorNotificationState extends State<InspectorNotification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications",style: TextStyle(color: Colors.white),),
        backgroundColor: TizaraaColors.Tizara,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("00",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
          )
        ],
      ),

      body: Center(
        child: Text("Coming Soon...",style: TextStyle(fontSize: 30),),
      ),
    );
  }
}
