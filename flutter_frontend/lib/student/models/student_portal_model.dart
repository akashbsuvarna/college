class StudentPortalModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String studentId;
  final String dob;
  final String caste;
  final String bloodGroup;
  final String permanentAddress;
  final ParentInfo father;
  final ParentInfo mother;
  final AcademicPortalInfo academic;
  final SSLCInfo sslc;
  final PUCInfo puc;
  final String status;

  StudentPortalModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.studentId = '',
    required this.dob,
    required this.caste,
    required this.bloodGroup,
    required this.permanentAddress,
    required this.father,
    required this.mother,
    required this.academic,
    required this.sslc,
    required this.puc,
    required this.status,
  });

  factory StudentPortalModel.fromJson(Map<String, dynamic> json) {
    return StudentPortalModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      studentId: json['studentId'] ?? '',
      dob: json['dob'] ?? '',
      caste: json['caste'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      permanentAddress: json['permanentAddress'] ?? '',
      father: ParentInfo.fromJson(json['father'] ?? {}),
      mother: ParentInfo.fromJson(json['mother'] ?? {}),
      academic: AcademicPortalInfo.fromJson(json['academic'] ?? {}),
      sslc: SSLCInfo.fromJson(json['sslc'] ?? {}),
      puc: PUCInfo.fromJson(json['puc'] ?? {}),
      status: json['status'] ?? 'active',
    );
  }
}

class ParentInfo {
  final String name;
  final String occupation;
  final String mobile;

  ParentInfo({required this.name, required this.occupation, required this.mobile});

  factory ParentInfo.fromJson(Map<String, dynamic> json) => ParentInfo(
        name: json['name'] ?? '',
        occupation: json['occupation'] ?? '',
        mobile: json['mobile'] ?? '',
      );
}

class AcademicPortalInfo {
  final String course;
  final int semester;

  AcademicPortalInfo({required this.course, required this.semester});

  factory AcademicPortalInfo.fromJson(Map<String, dynamic> json) =>
      AcademicPortalInfo(
        course: json['course'] ?? '',
        semester: json['semester'] ?? 1,
      );
}

class SSLCInfo {
  final String school;
  final double percentage;
  final String board;

  SSLCInfo({required this.school, required this.percentage, required this.board});

  factory SSLCInfo.fromJson(Map<String, dynamic> json) => SSLCInfo(
        school: json['school'] ?? '',
        percentage: (json['percentage'] ?? 0).toDouble(),
        board: json['board'] ?? '',
      );
}

class PUCInfo {
  final String college;
  final double percentage;
  final String course;

  PUCInfo({required this.college, required this.percentage, required this.course});

  factory PUCInfo.fromJson(Map<String, dynamic> json) => PUCInfo(
        college: json['college'] ?? '',
        percentage: (json['percentage'] ?? 0).toDouble(),
        course: json['course'] ?? '',
      );
}

class AttendanceRecord {
  final String id;
  final String studentId;
  final String subjectName;
  final String subjectCode;
  final String sessionId;
  final String date;
  final String status;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.subjectName,
    required this.subjectCode,
    required this.sessionId,
    required this.date,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final subject = json['subjectId'];
    return AttendanceRecord(
      id: json['_id'] ?? '',
      studentId: json['studentId'] ?? '',
      subjectName: subject is Map ? (subject['name'] ?? 'Daily Attendance') : 'Daily Attendance',
      subjectCode: subject is Map ? (subject['code'] ?? '') : 'Daily',
      sessionId: json['sessionId'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? 'present',
    );
  }
}

class StudentNotification {
  final String id;
  final String title;
  final String message;
  final String target;
  final String createdAt;

  StudentNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.target,
    required this.createdAt,
  });

  factory StudentNotification.fromJson(Map<String, dynamic> json) {
    return StudentNotification(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      target: json['target'] ?? 'all',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
