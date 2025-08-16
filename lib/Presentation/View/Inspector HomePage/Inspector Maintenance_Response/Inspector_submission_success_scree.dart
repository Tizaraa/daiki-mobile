// import 'package:daiki_axis_stp/Presentation/View/HomePageDir/Inspector_Dashboard.dart';
// import 'package:flutter/material.dart';
//
// class SubmissionSuccessScreen extends StatelessWidget {
//   final String maintenanceId;
//   final int projectId;
//   final int johkasouId;
//
//   const SubmissionSuccessScreen({
//     Key? key,
//     required this.maintenanceId,
//     required this.projectId,
//     required this.johkasouId,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Submission Success'),
//         automaticallyImplyLeading: false, // Prevent back button
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.check_circle,
//               color: Colors.green,
//               size: 80,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Maintenance Report Submitted Successfully!',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//               textAlign: TextAlign.center,
//             ),
//
//             Text("Maintenance Schedule ID: $maintenanceId"),
//             Text("Project ID: $projectId"),
//             Text("Johkasou ID: $johkasouId"),
//
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                // Navigator.popUntil(context, (route) => route.isFirst);
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => Inspector_Dashboard(),));
//                 print("output : ${Inspector_Dashboard()}");
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                 backgroundColor: Colors.blue,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text(
//                 'Return to Home',
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }