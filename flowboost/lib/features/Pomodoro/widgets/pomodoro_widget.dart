import 'package:flutter/material.dart';
import '../../../common/constants/constants.dart';

// Widget Container Retro
class RetroContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double borderRadius;
  // Tambah opsi untuk mematikan shadow (berguna saat task tidak dipilih)
  final bool hasShadow;

  const RetroContainer({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 20.0,
    this.hasShadow = true, // Default ada shadow
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Default gunakan kCardColor yang sudah ada, tapi bisa di-override
        color: backgroundColor ?? kCardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: hasShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ] : [],
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: child,
    );
  }
}

// Tombol Retro (Untuk START/PAUSE)
class RetroButtonPomodoro extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final double? width;

  const RetroButtonPomodoro({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // GUNAKAN KONSTANTA BARU: kPomodoroPrimaryColor (Hijau Olive)
          backgroundColor: color ?? kPomodoroPrimaryColor,
          foregroundColor: kTextColor,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: kPomodoroPrimaryColor.withOpacity(0.8), width: 1.5)
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
      ),
    );
  }
}

// Tombol Mode (Pomodoro, Short Break, dll)
// Tombol Mode (Pomodoro, Short Break, dll)
class ModeButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const ModeButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // UBAH 1: Gunakan Alignment center agar teks benar-benar di tengah container
        alignment: Alignment.center,
        // UBAH 2: Kurangi padding vertical (tinggi) dan horizontal (lebar dalam)
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
            color: isSelected ? kPomodoroPrimaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? [] : [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0,3))
            ],
            border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300)
        ),
        child: Text(
          text,
          // UBAH 3: Pastikan teks rata tengah (center) jika turun baris
          textAlign: TextAlign.center,
          style: TextStyle(
            // UBAH 4: Kecilkan sedikit font size agar muat (misal 13 atau 14)
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: kTextColor.withOpacity(isSelected ? 1 : 0.6),
          ),
        ),
      ),
    );
  }
}