// import 'package:flutter/material.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';

// class OtpVerificationScreen extends StatelessWidget {
//   const OtpVerificationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // --- Konstanta Desain ---
//     const Color primaryColor = Colors.black;
//     const Color instructionColor = Colors.grey;
//     const Color backgroundColor = Color.fromARGB(255, 245, 240, 227); // Warna latar belakang krem
//     const Color buttonColor = Colors.green; // Warna tombol Verifikasi hijau

//     // --- Controller untuk Input Kode (Opsional, untuk mengambil nilai) ---
//     TextEditingController textEditingController = TextEditingController();

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         // Tombol kembali (<-)
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: primaryColor),
//           onPressed: () {
//             // Logika navigasi kembali
//             Navigator.pop(context);
//           },
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         // Untuk menjaga warna ikon tetap hitam jika AppBar tidak transparan
//         iconTheme: const IconThemeData(color: primaryColor),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             const SizedBox(height: 10),

//             // 1. Judul Halaman
//             const Text(
//               'ENTER VERIFICATION CODE',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: primaryColor,
//               ),
//             ),
//             const SizedBox(height: 8),

//             // 2. Teks Instruksi
//             Text(
//               'Verify your number with the 6-digit code we just sent via SMS. The code Expires in 30 minutes',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: instructionColor,
//               ),
//             ),
//             const SizedBox(height: 40),

//             // 3. Kotak Input Kode (Pin Code Fields)
//             PinCodeTextField(
//               appContext: context,
//               length: 6, // 6 digit sesuai gambar
//               obscureText: false,
//               animationType: AnimationType.fade,
//               keyboardType: TextInputType.number,
//               controller: textEditingController,
//               pinTheme: PinTheme(
//                 shape: PinCodeFieldShape.box, // Bentuk kotak
//                 borderRadius: BorderRadius.circular(8),
//                 fieldHeight: 50, // Tinggi kotak
//                 fieldWidth: 40, // Lebar kotak
//                 activeFillColor: Colors.transparent,
//                 inactiveFillColor: Colors.transparent,
//                 selectedFillColor: Colors.transparent,
//                 activeColor: primaryColor, // Border saat aktif
//                 inactiveColor: primaryColor, // Border saat tidak aktif
//                 selectedColor: primaryColor, // Border saat terpilih
//                 // Style teks di dalam kotak
//                 fieldOuterDecoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: primaryColor, width: 1.5),
//                 ),
//                 // Style teks yang diketik
//                 textStyle: const TextStyle(
//                   fontSize: 20, 
//                   fontWeight: FontWeight.bold, 
//                   color: primaryColor,
//                 ),
//               ),
//               animationDuration: const Duration(milliseconds: 300),
//               // Warna latar belakang keseluruhan tidak diisi (transparan)
//               enableActiveFill: false,
//               onChanged: (value) {
//                 // Logika saat kode berubah (misalnya, memicu verifikasi otomatis)
//                 print(value);
//               },
//               beforeTextPaste: (text) {
//                 // Mencegah paste teks selain angka
//                 return true;
//               },
//             ),

//             const SizedBox(height: 20),

//             // 4. Tautan Resend (Kirim Ulang)
//             Row(
//               children: [
//                 const Text(
//                   "Didn't receive the code? ",
//                   style: TextStyle(fontSize: 14, color: primaryColor),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     // Logika untuk mengirim ulang kode
//                     print('Tombol Resend Ditekan');
//                   },
//                   child: const Text(
//                     'Resend',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: buttonColor, // Warna hijau
//                       decoration: TextDecoration.underline,
//                       fontWeight: FontWeight.bold,
//                       decorationColor: buttonColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             // Spacer untuk mendorong tombol ke bawah
//             const Spacer(),

//             // 5. Tombol Verifikasi
//             Padding(
//               padding: const EdgeInsets.only(bottom: 24.0),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Logika verifikasi
//                     String code = textEditingController.text;
//                     print('Verifikasi kode: $code');
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: buttonColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'Verify',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }