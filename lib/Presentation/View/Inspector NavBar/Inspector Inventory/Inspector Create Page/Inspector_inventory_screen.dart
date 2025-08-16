import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../Core/Utils/colors.dart';
import '../Inspector Maintenance Kit/Inspector_maintenance_kit_screen.dart';
import '../Inspector Spare Parts/Inspector_spare_parts.dart';
import '../Inspector Testing Apparatus/Inspector_testing_screen.dart';


class Inspector_InventoryScreen extends StatefulWidget {
  const Inspector_InventoryScreen({super.key});

  @override
  State<Inspector_InventoryScreen> createState() => _Inspector_InventoryScreenState();
}

class _Inspector_InventoryScreenState extends State<Inspector_InventoryScreen> {


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF0F8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Inventories"),
        ),
        backgroundColor: Colors.transparent, // Make scaffold background transparent to show gradient
        body: Center(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height/10,),

              GestureDetector(
                onTap: () {
                  setState(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => InspectorTestingInventoryScreen()));
                  });
                },
                child: Card(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFF0F8FF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    height: 90,
                    width: MediaQuery.of(context).size.width/1.1,
                    child: Center(child: Text("Testing Apparatus", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,
                        color: TizaraaColors.Tizara),)),
                  ),
                ),
              ),

              SizedBox(height: 20), // Added spacing between cards

              GestureDetector(
                onTap: () {
                  setState(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Inspector_MaintenanceKitListScreen(),));
                  });
                },
                child: Card(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFF0F8FF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    height: 90,
                    width: MediaQuery.of(context).size.width/1.1,
                    child: Center(child: Text("Maintenance Kit List", style: TextStyle(fontWeight: FontWeight.bold,
                       fontSize: 20, color: TizaraaColors.Tizara),)),
                  ),
                ),
              ),

              SizedBox(height: 20), // Added spacing between cards

              GestureDetector(
                onTap: () {
                  setState(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => InspectorSparePartsScreen(),));
                  });
                },
                child: Card(

                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFF0F8FF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    height: 90,
                    width: MediaQuery.of(context).size.width/1.1,
                    child: Center(child: Text("Spare Parts", style: TextStyle(fontWeight: FontWeight.bold,
                       fontSize: 20, color: TizaraaColors.Tizara),)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}