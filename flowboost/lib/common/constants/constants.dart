import 'package:flutter/material.dart';

// --- KONSTANTA WARNA (YANG SUDAH ADA - TIDAK DIUBAH) ---
const Color kBackgroundColor = Color(0xFFFDF8E2); // Krem background
const Color kAppBarColor = Color(0xFFD0DDB7);     // Hijau sage
const Color kCardColor = Color(0xFFE6EFD3);       // Hijau muda kartu
const Color kButtonColor = Color(0xFFF3E7D3);     // Beige tombol
const Color kProgressDoneColor = Color(0xFF6699CC); // Biru progress
const Color kTextColor = Colors.black;

// --- GAYA TEKS (YANG SUDAH ADA - TIDAK DIUBAH) ---
const TextStyle kHeaderStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: kTextColor,
);

const TextStyle kLabelStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: kTextColor,
);

// =================================================================
// --- PENAMBAHAN WARNA KHUSUS POMODORO (SESUAI DESAIN) ---
// =================================================================

// Warna hijau olive untuk tombol "Start", toggle mode aktif, dan checkbox selesai
const Color kPomodoroPrimaryColor = Color(0xFFC4CE8F);

// Warna abu-abu gelap untuk tombol "Save" dan "Cancel" pada mode edit
const Color kPomodoroDarkButtonColor = Color(0xFF4A4A4A);

// Warna background untuk item task saat TIDAK dipilih (agak beige gelap)
const Color kTaskInactiveBgColor = Color(0xFFF3EEDD);

// Warna abu-abu terang untuk border checkbox yang BELUM selesai
const Color kTaskNotDoneColor = Color(0xFFE0E0E0);

// Gaya teks besar khusus untuk Timer
const TextStyle kTimerTextStyle = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w400,
    color: kTextColor,
    letterSpacing: 2.0
);