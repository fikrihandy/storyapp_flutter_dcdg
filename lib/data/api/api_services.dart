import 'dart:convert';
import 'dart:typed_data';
import 'package:declarative_navigation/data/model/stories_response.dart';
import 'package:declarative_navigation/data/model/register_model.dart';
import 'package:http/http.dart' as http;
import '../model/detail_story_response.dart';
import '../model/login_model.dart';
import '../model/login_response.dart';
import '../model/register_response.dart';
import '../model/upload_response.dart';

class ApiServices {
  static const String _baseUrl = "https://story-api.dicoding.dev/v1";

  Future<RegisterResponse> register(
    RegisterModel user,
  ) async {
    final uri = Uri.parse("$_baseUrl/register");

    final body = jsonEncode({
      'name': user.name,
      'email': user.email,
      'password': user.password,
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      return RegisterResponse.fromJson(jsonDecode(response.body));
    } else {
      final errorMessage = jsonDecode(response.body)['message'];
      throw Exception(errorMessage);
    }
  }

  Future<LoginResponse> login(
    LoginModel user,
  ) async {
    final uri = Uri.parse("$_baseUrl/login");

    final body = jsonEncode({
      'email': user.email,
      'password': user.password,
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      final errorMessage = jsonDecode(response.body)['message'];
      throw Exception(errorMessage);
    }
  }

  Future<GetAllStoriesResponse> getStories(String token) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/stories"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return GetAllStoriesResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load stories');
    }
  }

  Future<DetailStoryResponse> getStory(String storyId, String token) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/stories/$storyId"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return DetailStoryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load story');
    }
  }

  Future<UploadResponse> uploadDocument(
    List<int> bytes,
    String fileName,
    String description,
    String token,
  ) async {
    final uri = Uri.parse("$_baseUrl/stories");
    var request = http.MultipartRequest('POST', uri);

    final multiPartFile = http.MultipartFile.fromBytes(
      "photo",
      bytes,
      filename: fileName,
    );
    final Map<String, String> fields = {
      "description": description,
    };
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      "Content-type": "multipart/form-data",
    };

    request.files.add(multiPartFile);
    request.fields.addAll(fields);
    request.headers.addAll(headers);

    final http.StreamedResponse streamedResponse = await request.send();
    final int statusCode = streamedResponse.statusCode;

    final Uint8List responseList = await streamedResponse.stream.toBytes();
    final String responseData = String.fromCharCodes(responseList);

    if (statusCode == 201) {
      final UploadResponse uploadResponse = UploadResponse.fromJson(
        responseData,
      );
      return uploadResponse;
    } else {
      throw Exception("Upload file error");
    }
  }
}
