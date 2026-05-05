class Subject {
  final String? id;
  final String name;
  final String code;
  final String courseId;
  final String? courseName;
  final int credits;

  Subject({
    this.id,
    required this.name,
    required this.code,
    required this.courseId,
    this.courseName,
    this.credits = 3,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['_id'],
      name: json['name'],
      code: json['code'],
      courseId: (json['courseId'] is Map) ? json['courseId']['_id'] : json['courseId'],
      courseName: (json['courseId'] is Map) ? json['courseId']['title'] : null,
      credits: json['credits'] ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'courseId': courseId,
      'credits': credits,
    };
  }
}
