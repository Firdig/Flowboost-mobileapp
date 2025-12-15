import 'package:flutter/material.dart';

// Anda dapat mengganti 'flowboost_logo.png' dengan path ke gambar logo Anda
// Pastikan gambar logo Anda ada di folder 'assets' dan telah dideklarasikan di pubspec.yaml
const String logoPath = '../../../../../assets/flowboost_logo.png'; 

class FlowboostSignUpScreen extends StatelessWidget {
  const FlowboostSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema warna dan teks yang mendekati gambar
    const Color primaryTextColor = Colors.black;
    const Color hintTextColor = Colors.grey;
    const Color inputFillColor = Colors.black; // Latar belakang input hitam
    const Color inputBorderColor = Colors.transparent; // Border transparan
    const Color buttonColor = Color.fromARGB(255, 108, 150, 180); // Warna tombol biru
    const TextStyle labelStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: primaryTextColor);

    // Padding yang konsisten untuk seluruh layar
    const double screenPadding = 24.0;
    // Jarak antara setiap elemen input
    const double fieldSpacing = 16.0;
    // Radius sudut input
    const double borderRadius = 8.0;

    // Untuk memastikan tampilan tetap bisa di-scroll jika keyboard muncul
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 240, 227), // Warna latar belakang krem
      appBar: AppBar(
        // AppBar di sini hanya untuk konsistensi, bisa dihilangkan jika tidak perlu
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // Sembunyikan AppBar
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: screenPadding, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 1. Logo Aplikasi (Ganti dengan Widget Image atau SVG Anda)
              const SizedBox(height: 120, child: Icon(Icons.favorite, size: 80, color: primaryTextColor)),
              // Jika Anda menggunakan gambar yang sama persis:
              // Image.asset(logoPath, height: 120), 
              
              const SizedBox(height: 10),
              
              // 2. Nama Aplikasi
              const Text(
                'Flowboost',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              // Tambahkan TM jika perlu:
              const Text(
                '™',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),

              const SizedBox(height: 40),
              
              // 3. Form Input
              _buildInputField(
                label: 'Nickname',
                hintText: 'Username',
                labelStyle: labelStyle,
                fillColor: inputFillColor,
                hintTextColor: hintTextColor,
                borderRadius: borderRadius,
              ),
              SizedBox(height: fieldSpacing),
              _buildInputField(
                label: 'Email',
                hintText: 'Email',
                labelStyle: labelStyle,
                fillColor: inputFillColor,
                hintTextColor: hintTextColor,
                borderRadius: borderRadius,
              ),
              SizedBox(height: fieldSpacing),
              _buildInputField(
                label: 'Phone number',
                hintText: 'Phone number',
                keyboardType: TextInputType.phone,
                labelStyle: labelStyle,
                fillColor: inputFillColor,
                hintTextColor: hintTextColor,
                borderRadius: borderRadius,
              ),
              SizedBox(height: fieldSpacing),
              _buildInputField(
                label: 'Password',
                hintText: 'Password',
                isPassword: true,
                labelStyle: labelStyle,
                fillColor: inputFillColor,
                hintTextColor: hintTextColor,
                borderRadius: borderRadius,
              ),
              SizedBox(height: fieldSpacing),
              _buildInputField(
                label: 'Confirmation Password',
                hintText: 'Confirm Password',
                isPassword: true,
                labelStyle: labelStyle,
                fillColor: inputFillColor,
                hintTextColor: hintTextColor,
                borderRadius: borderRadius,
              ),

              const SizedBox(height: 30),
              
              // 4. Tombol Register
              ElevatedButton(
                onPressed: () {
                  // Tambahkan logika pendaftaran di sini
                  print('Tombol Register Ditekan');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  minimumSize: const Size(double.infinity, 50), // Ukuran tombol
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 5. Link Log in
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Already have an Account? ',
                    style: TextStyle(color: primaryTextColor, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Tambahkan navigasi ke layar Log In
                      print('Link Log in Ditekan');
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        color: buttonColor, // Warna biru seperti tombol
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        decorationColor: buttonColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pembantu untuk membuat Label dan TextField
  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextStyle labelStyle,
    required Color fillColor,
    required Color hintTextColor,
    required double borderRadius,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label di atas TextField
        Text(
          label,
          style: labelStyle,
        ),
        const SizedBox(height: 4), // Jarak antara label dan input
        
        // TextField
        TextField(
          keyboardType: keyboardType,
          obscureText: isPassword, // Sembunyikan teks jika ini adalah password
          style: const TextStyle(color: Colors.white), // Warna teks yang diketik putih
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: hintTextColor.withOpacity(0.7)),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            // Menghilangkan border dan membuatnya rata
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none, // Menghilangkan garis tepi
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}