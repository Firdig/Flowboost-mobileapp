import 'package:uuid/uuid.dart';

class PomodoroTask {
  final String id;
  String title;
  int completedSessions;
  int targetSessions;
  String? note;
  bool isDone;

  PomodoroTask({
    String? id,
    required this.title,
    this.completedSessions = 0,
    required this.targetSessions,
    this.note,
    this.isDone = false,
  }) : id = id ?? const Uuid().v4();
}