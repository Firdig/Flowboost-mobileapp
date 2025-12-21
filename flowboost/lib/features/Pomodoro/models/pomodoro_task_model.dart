// FILE: lib/features/Pomodoro/models/pomodoro_task_model.dart
import 'package:uuid/uuid.dart';

class SubTask {
  final String id;
  String title;
  int completedSessions;
  int targetSessions;
  bool isDone;

  SubTask({
    String? id,
    required this.title,
    this.completedSessions = 0,
    required this.targetSessions,
    this.isDone = false,
  }) : id = id ?? const Uuid().v4();

  // Konversi ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completedSessions': completedSessions,
      'targetSessions': targetSessions,
      'isDone': isDone,
    };
  }

  // Ambil dari Map Firestore
  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'],
      title: map['title'] ?? '',
      completedSessions: map['completedSessions'] ?? 0,
      targetSessions: map['targetSessions'] ?? 1,
      isDone: map['isDone'] ?? false,
    );
  }
}

class PomodoroTask {
  final String id;
  String title;
  int completedSessions;
  int targetSessions;
  String? note;
  bool isDone;
  List<SubTask>? subTasks;

  PomodoroTask({
    String? id,
    required this.title,
    this.completedSessions = 0,
    required this.targetSessions,
    this.note,
    this.isDone = false,
    this.subTasks,
  }) : id = id ?? const Uuid().v4();

  // Konversi ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completedSessions': completedSessions,
      'targetSessions': targetSessions,
      'note': note,
      'isDone': isDone,
      // Convert list subtasks ke list map
      'subTasks': subTasks?.map((x) => x.toMap()).toList(),
    };
  }

  // Ambil dari Map Firestore
  factory PomodoroTask.fromMap(Map<String, dynamic> map) {
    return PomodoroTask(
      id: map['id'],
      title: map['title'] ?? '',
      completedSessions: map['completedSessions'] ?? 0,
      targetSessions: map['targetSessions'] ?? 1,
      note: map['note'],
      isDone: map['isDone'] ?? false,
      subTasks: map['subTasks'] != null
          ? List<SubTask>.from(
              (map['subTasks'] as List).map((x) => SubTask.fromMap(x)))
          : [],
    );
  }
}