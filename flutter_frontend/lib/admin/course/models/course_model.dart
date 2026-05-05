class Course {
  final String? id;
  final String title;
  final String description;
  final String duration;
  final String code;

  Course({
    this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.code,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'duration': duration,
      'code': code,
    };
  }
}
