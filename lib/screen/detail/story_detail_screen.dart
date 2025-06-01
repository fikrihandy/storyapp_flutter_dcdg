import 'dart:async';
import 'package:declarative_navigation/provider/story_provider.dart';
import 'package:declarative_navigation/static/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../static/detail_story_result_state.dart';
import 'body_of_detail_screen_widget.dart';
import '../../provider/sharedpref_provider.dart';

class DetailScreen extends StatefulWidget {
  final String storyId;

  const DetailScreen({
    super.key,
    required this.storyId,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final sharedPrefProvider = context.read<SharedPrefProvider>();
      final token = await sharedPrefProvider.getUserToken();

      if (token?.token != null) {
        context.read<StoryProvider>().fetchStory(
              widget.storyId,
              token!.token!,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(storyDetailPage),
      ),
      body: Consumer<StoryProvider>(builder: (_, value, __) {
        return switch (value.resultState) {
          StoryLoadingState() =>
            const Center(child: CircularProgressIndicator()),
          StoryLoadedState(data: var story) =>
            BodyOfDetailScreenWidget(story: story),
          StoryErrorState(error: var message) => Center(child: Text(message)),
          _ => const SizedBox(),
        };
      }),
    );
  }
}
