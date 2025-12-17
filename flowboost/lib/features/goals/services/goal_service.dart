import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal_model.dart';

class GoalService {
  final CollectionReference _goalsCollection =
      FirebaseFirestore.instance.collection('goals');
  
  // Mendapatkan User ID saat ini
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // CREATE: Tambah Goal Baru
  Future<void> addGoal(GoalModel goal) async {
    await _goalsCollection.add(goal.toMap());
  }

  // READ: Stream daftar goals user (Realtime)
  Stream<List<GoalModel>> getGoalsStream() {
    return _goalsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => GoalModel.fromFirestore(doc)).toList();
    });
  }

  // UPDATE: Update progress task
  Future<void> updateGoal(GoalModel goal) async {
    if (goal.id != null) {
      await _goalsCollection.doc(goal.id).update(goal.toMap());
    }
  }

  // DELETE: Hapus Goal
  Future<void> deleteGoal(String goalId) async {
    await _goalsCollection.doc(goalId).delete();
  }
}