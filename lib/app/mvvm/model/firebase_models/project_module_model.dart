import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModuleModel {
  final String id;
  final String? projectId;
  final String? moduleName;
  final String? platformStack;
  final String? assignedDevId;
  final DateTime? designLockedDate;
  final DateTime? devStartDate;
  final DateTime? selfQaDate;
  final DateTime? leadSignoffDate;
  final DateTime? pmReviewDate;
  final String? ctoReviewStatus;
  final String? clientReadyStatus;
  final String? status;
  final DateTime? eta;
  final String? sprint;
  final String? notes;

  ProjectModuleModel({
    required this.id,
    this.projectId,
    this.moduleName,
    this.platformStack,
    this.assignedDevId,
    this.designLockedDate,
    this.devStartDate,
    this.selfQaDate,
    this.leadSignoffDate,
    this.pmReviewDate,
    this.ctoReviewStatus,
    this.clientReadyStatus,
    this.status,
    this.eta,
    this.sprint,
    this.notes,
  });

  factory ProjectModuleModel.fromJson(Map<String, dynamic> json) {
    return ProjectModuleModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String?,
      moduleName: json['module_name'] as String?,
      platformStack: json['platform_stack'] as String?,
      assignedDevId: json['assigned_dev_id'] as String?,
      designLockedDate: (json['design_locked_date'] as Timestamp?)?.toDate(),
      devStartDate: (json['dev_start_date'] as Timestamp?)?.toDate(),
      selfQaDate: (json['self_qa_date'] as Timestamp?)?.toDate(),
      leadSignoffDate: (json['lead_signoff_date'] as Timestamp?)?.toDate(),
      pmReviewDate: (json['pm_review_date'] as Timestamp?)?.toDate(),
      ctoReviewStatus: json['cto_review_status'] as String?,
      clientReadyStatus: json['client_ready_status'] as String?,
      status: json['status'] as String?,
      eta: (json['eta'] as Timestamp?)?.toDate(),
      sprint: json['sprint'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'module_name': moduleName,
      'platform_stack': platformStack,
      'assigned_dev_id': assignedDevId,
      'design_locked_date': designLockedDate != null ? Timestamp.fromDate(designLockedDate!) : null,
      'dev_start_date': devStartDate != null ? Timestamp.fromDate(devStartDate!) : null,
      'self_qa_date': selfQaDate != null ? Timestamp.fromDate(selfQaDate!) : null,
      'lead_signoff_date': leadSignoffDate != null ? Timestamp.fromDate(leadSignoffDate!) : null,
      'pm_review_date': pmReviewDate != null ? Timestamp.fromDate(pmReviewDate!) : null,
      'cto_review_status': ctoReviewStatus,
      'client_ready_status': clientReadyStatus,
      'status': status,
      'eta': eta != null ? Timestamp.fromDate(eta!) : null,
      'sprint': sprint,
      'notes': notes,
    };
  }
}