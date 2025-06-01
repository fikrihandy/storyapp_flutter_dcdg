import '../data/model/story.dart';

sealed class StoryResultState {}

class StoryNoneState extends StoryResultState {}

class StoryLoadingState extends StoryResultState {}

class StoryErrorState extends StoryResultState {
  final String error;

  StoryErrorState(this.error);
}

class StoryLoadedState extends StoryResultState {
  final Story data;

  StoryLoadedState(this.data);
}
