
import 'package:daiki_axis_stp/Presentation/View/Inspector%20HomePage/Inspector%20Project/projects_screen.dart';
import 'package:flutter/material.dart';

import 'create_project.dart';

class Inspector_ProjectsHomepage extends StatefulWidget {
  const Inspector_ProjectsHomepage({super.key});

  @override
  State<Inspector_ProjectsHomepage> createState() => _Inspector_ProjectsHomepageState();
}

class _Inspector_ProjectsHomepageState extends State<Inspector_ProjectsHomepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Projects",style: TextStyle(fontWeight: FontWeight.normal,color: Colors.white)),
        backgroundColor: Color(0xFF00B2AE),
      ),
      body: Stack(
        children:[
          Positioned.fill(child: Opacity(opacity: 0.7,
              child: Image.asset('assets/bg1.jpg',fit: BoxFit.fill)),),

          Column(
          children: [
            SizedBox(height: 4,),
            Column(
            //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                           GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateProjectScreen(),)),
                  child: Card(
                    color: Colors.lightBlueAccent.withOpacity(0.5),
                    child: Container(
                      height: MediaQuery.of(context).size.height/9,
                      width: MediaQuery.of(context).size.width/1,
                      child: Padding(
                        padding: const EdgeInsets.all( 25.0),
                        child: Column(
                          children: [
                           // Icon(Icons.create_sharp,color: Color(0xFF0074BA),),
                            Text("Create Project",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24,color: Colors.white),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InspectorProjectListScreen(),)),
                  child: Card(
                    color: Colors.lightBlueAccent.withOpacity(0.5),
                    child: Container(
                      height: MediaQuery.of(context).size.height/9,
                      width: MediaQuery.of(context).size.width/1,
                      child: Padding(
                        padding: const EdgeInsets.all( 25.0),
                        child: Column(
                          children: [
                          //  Icon(Icons.list_alt,color: Color(0xFF0074BA),),
                            Text("Projects List",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24,color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),


              ],
            ),
          ],
        ),
    ],
      ),
    );
  }
}
