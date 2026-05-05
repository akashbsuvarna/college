enum BloodGroup { Apos, Aneg, Bpos, Bneg, ABpos, ABneg, Opos, Oneg }

class StudentModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String studentId;
  final String dob;
  final String caste;
  final BloodGroup bloodGroup;
  final String permanentAddress;
  final String status;

  final ParentModel father;
  final ParentModel mother;

  final AcademicInfo academic;
  final SSLCModel sslc;
  final PUCModel puc;

  StudentModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.studentId = '',
    required this.dob,
    required this.caste,
    required this.bloodGroup,
    required this.permanentAddress,
    this.status = 'active',
    required this.father,
    required this.mother,
    required this.academic,
    required this.sslc,
    required this.puc,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      studentId: json['studentId'] ?? '',
      dob: json['dob'] ?? '',
      caste: json['caste'] ?? '',
      bloodGroup: BloodGroup.values.firstWhere(
        (e) => e.name == json['bloodGroup'],
        orElse: () => BloodGroup.Opos,
      ),
      permanentAddress: json['permanentAddress'] ?? '',
      status: json['status'] ?? 'active',
      father: ParentModel.fromJson(json['father'] ?? {}),
      mother: ParentModel.fromJson(json['mother'] ?? {}),
      academic: AcademicInfo.fromJson(json['academic'] ?? {}),
      sslc: SSLCModel.fromJson(json['sslc'] ?? {}),
      puc: PUCModel.fromJson(json['puc'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'studentId': studentId,
      'dob': dob,
      'caste': caste,
      'bloodGroup': bloodGroup.name,
      'permanentAddress': permanentAddress,
      'status': status,
      'father': father.toJson(),
      'mother': mother.toJson(),
      'academic': academic.toJson(),
      'sslc': sslc.toJson(),
      'puc': puc.toJson(),
    };
  }
}

class ParentModel {
  final String name;
  final String occupation;
  final String mobile;

  ParentModel({required this.name, required this.occupation, required this.mobile});

  factory ParentModel.fromJson(Map<String, dynamic> json) => ParentModel(
        name: json['name'] ?? '',
        occupation: json['occupation'] ?? '',
        mobile: json['mobile'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'occupation': occupation,
        'mobile': mobile,
      };
}

class AcademicInfo {
  final String course;
  final int semester;

  AcademicInfo({required this.course, required this.semester});

  factory AcademicInfo.fromJson(Map<String, dynamic> json) => AcademicInfo(
        course: json['course'] ?? '',
        semester: json['semester'] ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'course': course,
        'semester': semester,
      };
}

class SSLCModel {
  final String school;
  final double percentage;
  final String board;

  SSLCModel({required this.school, required this.percentage, required this.board});

  factory SSLCModel.fromJson(Map<String, dynamic> json) => SSLCModel(
        school: json['school'] ?? '',
        percentage: (json['percentage'] ?? 0).toDouble(),
        board: json['board'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'school': school,
        'percentage': percentage,
        'board': board,
      };
}

class PUCModel {
  final String college;
  final double percentage;
  final String course;

  PUCModel({required this.college, required this.percentage, required this.course});

  factory PUCModel.fromJson(Map<String, dynamic> json) => PUCModel(
        college: json['college'] ?? '',
        percentage: (json['percentage'] ?? 0).toDouble(),
        course: json['course'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'college': college,
        'percentage': percentage,
        'course': course,
      };
}