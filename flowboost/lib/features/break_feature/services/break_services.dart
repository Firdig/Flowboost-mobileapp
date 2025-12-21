import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BreakLogModel {
  final String id;
  final String userId;
  final String type; // 'meditation', 'breathing', 'stretching'
  final int durationMinutes;
  final DateTime date;

  BreakLogModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.durationMinutes,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'type': type,
    'durationMinutes': durationMinutes,
    'date': Timestamp.fromDate(date),
  };

  factory BreakLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BreakLogModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'break',
      durationMinutes: data['durationMinutes'] ?? 0,
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}

class BreakService {
  final CollectionReference _breakCollection =
      FirebaseFirestore.instance.collection('break_logs');

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // 1. Simpan Log Baru (PANGGIL INI DI CONTROLLER)
  Future<void> logBreakActivity({
    required String type,
    required int durationMinutes,
  }) async {
    if (currentUserId.isEmpty) return;

    final newLog = BreakLogModel(
      id: '',
      userId: currentUserId,
      type: type,
      durationMinutes: durationMinutes,
      date: DateTime.now(),
    );

    await _breakCollection.add(newLog.toMap());
  }

  // 2. Ambil Data Stream untuk Statistik
  Stream<List<BreakLogModel>> getBreakLogsStream() {
    if (currentUserId.isEmpty) return Stream.value([]);
    return _breakCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BreakLogModel.fromFirestore(doc)).toList());
  }
}