import '../data/model/story.dart';

sealed class StoriesListResultState {}

class StoriesNoneState extends StoriesListResultState {}

class StoriesLoadingState extends StoriesListResultState {}

class StoriesErrorState extends StoriesListResultState {
  final String error;

  StoriesErrorState(this.error);
}

class StoriesLoadedState extends StoriesListResultState {
  final List<Story> data;

  StoriesLoadedState(this.data);
}
