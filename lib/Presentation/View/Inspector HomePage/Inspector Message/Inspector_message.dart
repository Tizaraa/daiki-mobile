import 'package:daiki_axis_stp/Core/Utils/colors.dart';
import 'package:flutter/material.dart';

class InspectorMessage extends StatefulWidget {
  const InspectorMessage({super.key});

  @override
  State<InspectorMessage> createState() => _InspectorMessageState();
}

class _InspectorMessageState extends State<InspectorMessage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Message",style: TextStyle(color: Colors.white),),
        backgroundColor: TizaraaColors.Tizara,
      ),

      body: Center(
        child: Text("Coming Soon...",style: TextStyle(fontSize: 30),),
      ),
    );
  }
}
