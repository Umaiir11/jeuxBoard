import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String? title;
  final String? stack;
  final String? sprint;
  final String? notes;
  final DateTime? eta;
  final String? createdBy;
  final DateTime? createdAt;
  final String? status;

  ProjectModel({
    required this.id,
    this.title,
    this.stack,
    this.sprint,
    this.notes,
    this.eta,
    this.createdBy,
    this.createdAt,
    this.status,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      title: json['title'] as String?,
      stack: json['stack'] as String?,
      sprint: json['sprint'] as String?,
      notes: json['notes'] as String?,
      eta: (json['eta'] as Timestamp?)?.toDate(),
      createdBy: json['created_by'] as String?,
      createdAt: (json['created_at'] as Timestamp?)?.toDate(),
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'stack': stack,
      'sprint': sprint,
      'notes': notes,
      'eta': eta != null ? Timestamp.fromDate(eta!) : null,
      'created_by': createdBy,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'status': status,
    };
  }
}