

// ignore_for_file: constant_identifier_names

enum TradeCategory {
  AIR_CONDITIONING,
  CARPENTRY,
  CLEANING,
  ELECTRICAL,
  GARDENING,
  GENERATOR_REPAIR,
  MASONRY,
  OTHER,
  PAINTING,
  PLUMBING,
  TILING,
  WELDING
}

enum BudgetType {
  DAILY,
  FIXED,
  HOURLY
}

enum UrgencyLevel {
  HIGH,
  LOW,
  MEDIUM,
  URGENT
}

enum JobStatus {
  ACTIVE,
  ASSIGNED,
  CANCELLED,
  COMPLETED,
  EXPIRED,
  IN_PROGRESS,
  PENDING
}

class JobRequest {
  final String title;
  final String description;
  final TradeCategory tradeCategory;
  final String? specificSkill;
  final String location;
  final double? latitude;
  final double? longitude;
  final BudgetType budgetType;
  final double budgetMin;
  final double budgetMax;
  final UrgencyLevel urgencyLevel;
  final String? preferredDate; // Format: "yyyy-MM-dd"
  final String? preferredTime;
  final List<String>? pictureUrls;

  JobRequest({
    required this.title,
    required this.description,
    required this.tradeCategory,
    this.specificSkill,
    required this.location,
    this.latitude,
    this.longitude,
    this.budgetType = BudgetType.FIXED,
    required this.budgetMin,
    required this.budgetMax,
    this.urgencyLevel = UrgencyLevel.MEDIUM,
    this.preferredDate,
    this.preferredTime,
    this.pictureUrls,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'tradeCategory': tradeCategory.name,
      'location': location,
      'budgetType': budgetType.name,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'urgencyLevel': urgencyLevel.name,
    };

    if (specificSkill != null) map['specificSkill'] = specificSkill;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (preferredDate != null) map['preferredDate'] = preferredDate;
    if (preferredTime != null) map['preferredTime'] = preferredTime;
    if (pictureUrls != null && pictureUrls!.isNotEmpty) {
      map['pictureUrls'] = pictureUrls;
    }

    return map;
  }
}

class JobClientResponse {
  final int id;
  final String fullName;
  final String phoneNumber;
  final double rating;
  final int totalReviews;

  JobClientResponse({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.rating,
    required this.totalReviews,
  });

  factory JobClientResponse.fromJson(Map<String, dynamic> json) {
    return JobClientResponse(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      rating: (json['rating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
    );
  }
}

class JobResponse {
  final int id;
  final String title;
  final String description;
  final TradeCategory tradeCategory;
  final String? specificSkill;
  final String location;
  final double? latitude;
  final double? longitude;
  final BudgetType budgetType;
  final double budgetMin;
  final double budgetMax;
  final UrgencyLevel urgencyLevel;
  final String? preferredDate;
  final String? preferredTime;
  final JobStatus status;
  final List<String>? pictureUrls;
  final int viewsCount;
  final int bidsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime expiresAt;
  final JobClientResponse client;

  JobResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.tradeCategory,
    this.specificSkill,
    required this.location,
    this.latitude,
    this.longitude,
    required this.budgetType,
    required this.budgetMin,
    required this.budgetMax,
    required this.urgencyLevel,
    this.preferredDate,
    this.preferredTime,
    required this.status,
    this.pictureUrls,
    required this.viewsCount,
    required this.bidsCount,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    required this.client,
  });

  factory JobResponse.fromJson(Map<String, dynamic> json) {
    return JobResponse(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      tradeCategory: TradeCategory.values.firstWhere(
        (e) => e.name == json['tradeCategory'],
      ),
      specificSkill: json['specificSkill'],
      location: json['location'] as String,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      budgetType: BudgetType.values.firstWhere(
        (e) => e.name == json['budgetType'],
      ),
      budgetMin: (json['budgetMin'] as num).toDouble(),
      budgetMax: (json['budgetMax'] as num).toDouble(),
      urgencyLevel: UrgencyLevel.values.firstWhere(
        (e) => e.name == json['urgencyLevel'],
      ),
      preferredDate: json['preferredDate'],
      preferredTime: json['preferredTime'],
      status: JobStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      pictureUrls: json['pictureUrls'] != null 
          ? List<String>.from(json['pictureUrls'])
          : null,
      viewsCount: json['viewsCount'] as int,
      bidsCount: json['bidsCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      client: JobClientResponse.fromJson(json['client'] as Map<String, dynamic>),
    );
  }
}