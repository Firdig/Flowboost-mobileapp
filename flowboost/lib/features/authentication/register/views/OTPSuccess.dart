// import 'package:flutter/material.dart';

// class VerificationSuccessScreen extends StatelessWidget {
//   const VerificationSuccessScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // --- Konstanta Desain ---
//     const Color primaryColor = Colors.black;
//     const Color instructionColor = Colors.grey;
//     const Color successIconColor = Colors.green; // Warna hijau untuk ikon
//     const Color backgroundColor = Color.fromARGB(255, 245, 240, 227); // Warna latar belakang krem
//     const Color buttonColor = Colors.green; // Warna tombol hijau

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32.0),
//           child: Column(
//             // Mengatur elemen agar berada di tengah layar secara vertikal
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               // 1. Ikon Verifikasi Berhasil (Centang dalam Lingkaran)
//               const Icon(
//                 Icons.check_circle, // Ikon centang
//                 size: 150,
//                 color: successIconColor,
//               ),
//               const SizedBox(height: 30),

//               // 2. Judul Utama
//               const Text(
//                 'Verification Successfull',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: primaryColor,
//                 ),
//               ),
//               const SizedBox(height: 10),

//               // 3. Sub-judul
//               const Text(
//                 'You are all set',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: primaryColor,
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // 4. Pesan Deskripsi
//               Text(
//                 'You can now use our application and enjoy the experience',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: instructionColor.shade700,
//                   height: 1.5,
//                 ),
//               ),

//               // Spacer untuk mendorong tombol ke bawah
//               // Di sini kita gunakan SizedBox yang besar karena tombol berada di paling bawah
//               const SizedBox(height: 150),
//             ],
//           ),
//         ),
//       ),
//       // Tombol di bagian bawah layar (Menggunakan bottomNavigationBar atau Align)
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: SizedBox(
//           width: double.infinity,
//           height: 55,
//           child: ElevatedButton(
//             onPressed: () {
//               // Logika navigasi ke Homepage
//               print('Navigasi ke Homepage');
//               // Contoh navigasi ke halaman baru:
//               // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: buttonColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Go to Homepage',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }