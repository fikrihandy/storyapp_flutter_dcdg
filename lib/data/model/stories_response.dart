import 'package:declarative_navigation/data/model/story.dart';

class GetAllStoriesResponse {
  final bool error;
  final String message;
  final List<Story> listStory;

  GetAllStoriesResponse({
    required this.error,
    required this.message,
    required this.listStory,
  });

  factory GetAllStoriesResponse.fromJson(Map<String, dynamic> json) =>
      GetAllStoriesResponse(
        error: json["error"],
        message: json["message"],
        listStory: List<Story>.from(
          json["listStory"].map(
            (x) => Story.fromJson(x),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "listStory": List<dynamic>.from(
          listStory.map(
            (x) => x.toJson(),
          ),
        ),
      };
}
