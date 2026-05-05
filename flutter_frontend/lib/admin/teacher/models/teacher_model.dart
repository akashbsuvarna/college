class TeacherModel {
  final String id;
  final String name;
  final String email;
  final String department;
  final String designation;
  final String phone;
  final String joiningDate;
  final String status; // 'active' | 'inactive' | 'on_leave'
  final int coursesAssigned;
  final String? avatarUrl;
  final String employeeId;
  final String qualification;
  final List<String> subjects;
  final String dob;

  TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.designation,
    required this.phone,
    required this.joiningDate,
    required this.status,
    required this.coursesAssigned,
    this.avatarUrl,
    required this.employeeId,
    required this.qualification,
    required this.subjects,
    required this.dob,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      department: json['department'] ?? '',
      designation: json['designation'] ?? '',
      phone: json['phone'] ?? '',
      joiningDate: json['joiningDate'] ?? '',
      status: json['status'] ?? 'active',
      coursesAssigned: json['coursesAssigned'] ?? 0,
      avatarUrl: json['avatarUrl'],
      employeeId: json['employeeId'] ?? '',
      qualification: json['qualification'] ?? '',
      subjects: List<String>.from(json['subjects'] ?? []),
      dob: json['dob'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'department': department,
      'designation': designation,
      'phone': phone,
      'joiningDate': joiningDate,
      'status': status,
      'coursesAssigned': coursesAssigned,
      'employeeId': employeeId,
      'qualification': qualification,
      'subjects': subjects,
      'dob': dob,
    };
  }

  TeacherModel copyWith({
    String? id,
    String? name,
    String? email,
    String? department,
    String? designation,
    String? phone,
    String? joiningDate,
    String? status,
    int? coursesAssigned,
    String? avatarUrl,
    String? employeeId,
    String? qualification,
    List<String>? subjects,
    String? dob,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      phone: phone ?? this.phone,
      joiningDate: joiningDate ?? this.joiningDate,
      status: status ?? this.status,
      coursesAssigned: coursesAssigned ?? this.coursesAssigned,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      employeeId: employeeId ?? this.employeeId,
      qualification: qualification ?? this.qualification,
      subjects: subjects ?? this.subjects,
      dob: dob ?? this.dob,
    );
  }

}
