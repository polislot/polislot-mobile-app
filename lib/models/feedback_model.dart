// lib/models/feedback_model.dart

class FeedbackModel {
  final int? feedbackId;
  final int? userId;
  final String category;
  final String feedbackType;
  final String title;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  FeedbackModel({
    this.feedbackId,
    this.userId,
    required this.category,
    required this.feedbackType,
    required this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      feedbackId: json['feedback_id'],
      userId: json['user_id'],
      category: json['category'] ?? '',
      feedbackType: json['feedback_type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'feedback_type': feedbackType,
      'title': title,
      if (description != null && description!.isNotEmpty) 
        'description': description,
    };
  }
}

// Response setelah submit feedback
class FeedbackResponse {
  final bool success;
  final String message;

  FeedbackResponse({
    required this.success,
    required this.message,
  });

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}