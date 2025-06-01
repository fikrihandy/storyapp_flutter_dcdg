import 'package:flutter/widgets.dart';
import '../data/api/api_services.dart';
import '../static/detail_story_result_state.dart';

class StoryProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  StoryProvider(
    this._apiServices,
  );

  StoryResultState _resultState = StoryNoneState();

  StoryResultState get resultState => _resultState;

  Future<void> fetchStory(String storyId, String token) async {
    try {
      _resultState = StoryLoadingState();
      notifyListeners();

      final result = await _apiServices.getStory(storyId, token);

      if (result.error) {
        _resultState = StoryErrorState(result.message);
        notifyListeners();
      } else {
        _resultState = StoryLoadedState(result.story);
        notifyListeners();
      }
    } on Exception catch (e) {
      _resultState = StoryErrorState(e.toString());
      notifyListeners();
    }
  }
}
