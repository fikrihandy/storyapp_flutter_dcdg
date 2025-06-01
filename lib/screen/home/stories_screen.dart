import 'package:declarative_navigation/provider/stories_provider.dart';
import 'package:declarative_navigation/screen/home/story_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/sharedpref_provider.dart';
import '../../static/stories_result_state.dart';
import '../../static/strings.dart';

class StoriesScreen extends StatefulWidget {
  final Function(String) onTapped;
  final Function() onLogout;
  final Function() onAddNewStory;

  const StoriesScreen({
    super.key,
    required this.onTapped,
    required this.onLogout,
    required this.onAddNewStory,
  });

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initializeStories());
  }

  Future<void> _initializeStories() async {
    final sharedPrefProvider =
        Provider.of<SharedPrefProvider>(context, listen: false);
    final userToken = await sharedPrefProvider.getUserToken();

    if (userToken?.token != null) {
      context.read<StoriesProvider>().fetchStories(userToken!.token!);
    }
  }

  Future<void> refreshStories() async {
    final sharedPrefProvider =
        Provider.of<SharedPrefProvider>(context, listen: false);
    final userToken = await sharedPrefProvider.getUserToken();

    if (userToken?.token != null) {
      context.read<StoriesProvider>().fetchStories(userToken!.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sharedPrefState = context.watch<SharedPrefProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(storiesPage), actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => widget.onAddNewStory(),
        ),
      ]),
      body: Consumer<StoriesProvider>(
        builder: (_, storiesProvider, __) {
          return switch (storiesProvider.resultState) {
            StoriesLoadingState() => const Center(
                child: CircularProgressIndicator(),
              ),
            StoriesLoadedState(data: var storyList) => RefreshIndicator(
                onRefresh: refreshStories,
                child: ListView.builder(
                  itemCount: storyList.length,
                  itemBuilder: (context, index) {
                    final story = storyList[index];
                    return StoryCard(
                      story: story,
                      onTap: () => widget.onTapped(story.id),
                    );
                  },
                ),
              ),
            StoriesErrorState(error: var message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: $message"),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: refreshStories,
                      child: const Text(retry),
                    ),
                  ],
                ),
              ),
            _ => const SizedBox(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final sharedPrefProvider = context.read<SharedPrefProvider>();
          final isCleared = await sharedPrefProvider.clearLoginSession();
          if (isCleared) widget.onLogout();
        },
        tooltip: logoutText,
        child: sharedPrefState.isLoadingLogout
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.logout),
      ),
    );
  }
}
