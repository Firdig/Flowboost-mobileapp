import 'package:uuid/uuid.dart';

// Class SubTask untuk sub-tasks
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
}

// Update class PomodoroTask
class PomodoroTask {
  final String id;
  String title;
  int completedSessions;
  int targetSessions;
  String? note;
  bool isDone;
  List<SubTask>? subTasks; // TAMBAHKAN property ini

  PomodoroTask({
    String? id,
    required this.title,
    this.completedSessions = 0,
    required this.targetSessions,
    this.note,
    this.isDone = false,
    this.subTasks, // TAMBAHKAN parameter ini
  }) : id = id ?? const Uuid().v4();
}