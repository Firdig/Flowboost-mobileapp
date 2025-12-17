import 'package:cloud_firestore/cloud_firestore.dart';

class SubTaskModel {
  String id; // ID Unik untuk kestabilan UI
  String title;
  bool isCompleted;

  SubTaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted
  };

  factory SubTaskModel.fromMap(Map<String, dynamic> map) {
    return SubTaskModel(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(), // Fallback ID
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class TaskModel {
  String id;
  String title;
  bool isCompleted;
  List<SubTaskModel> subtasks;

  TaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.subtasks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      subtasks: List<SubTaskModel>.from(
        (map['subtasks'] ?? []).map((x) => SubTaskModel.fromMap(x)),
      ),
    );
  }
}

class GoalModel {
  String? id;
  String userId;
  String title;
  String reward;
  List<TaskModel> tasks;
  Timestamp createdAt;

  GoalModel({
    this.id,
    required this.userId,
    required this.title,
    required this.reward,
    required this.tasks,
    required this.createdAt,
  });

  double get progress {
    if (tasks.isEmpty) return 0.0;
    int completed = tasks.where((t) => t.isCompleted).length;
    return completed / tasks.length;
  }

  bool get isFinished => progress >= 1.0;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'reward': reward,
      'tasks': tasks.map((x) => x.toMap()).toList(),
      'createdAt': createdAt,
    };
  }

  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      reward: data['reward'] ?? '',
      tasks: List<TaskModel>.from(
        (data['tasks'] ?? []).map((x) => TaskModel.fromMap(x)),
      ),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}