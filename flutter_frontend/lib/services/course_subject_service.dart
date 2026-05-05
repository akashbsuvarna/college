import 'dart:convert';
import 'base_api_service.dart';

class CourseService extends BaseApiService {
  Future<List<dynamic>> getCourses() async {
    final response = await get("/admin/courses");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Failed to load courses");
  }

  Future<dynamic> createCourse(Map<String, dynamic> data) async {
    final response = await post("/admin/courses", data);
    return jsonDecode(response.body);
  }

  Future<dynamic> updateCourse(String id, Map<String, dynamic> data) async {
    final response = await put("/admin/courses/$id", data);
    return jsonDecode(response.body);
  }

  Future<void> deleteCourse(String id) async {
    await delete("/admin/courses/$id");
  }
}

class SubjectService extends BaseApiService {
  Future<List<dynamic>> getSubjects({String? courseId}) async {
    final path = courseId != null ? "/admin/subjects?courseId=$courseId" : "/admin/subjects";
    final response = await get(path);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Failed to load subjects");
  }

  Future<dynamic> createSubject(Map<String, dynamic> data) async {
    final response = await post("/admin/subjects", data);
    return jsonDecode(response.body);
  }

  Future<void> deleteSubject(String id) async {
    await delete("/admin/subjects/$id");
  }
}
