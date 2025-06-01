import 'package:flutter/widgets.dart';
import '../data/api/api_services.dart';
import '../../static/stories_result_state.dart';

class StoriesProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  StoriesProvider(
    this._apiServices,
  );

  StoriesListResultState _resultState = StoriesNoneState();

  StoriesListResultState get resultState => _resultState;

  Future<void> fetchStories(String token) async {
    try {
      _resultState = StoriesLoadingState();
      notifyListeners();

      final result = await _apiServices.getStories(token);

      if (result.error) {
        _resultState = StoriesErrorState(result.message);
        notifyListeners();
      } else {
        _resultState = StoriesLoadedState(result.listStory);
        notifyListeners();
      }
    } on Exception catch (e) {
      _resultState = StoriesErrorState(e.toString());
      notifyListeners();
    }
  }
}
