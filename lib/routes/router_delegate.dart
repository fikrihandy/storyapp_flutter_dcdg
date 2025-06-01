import 'package:camera/camera.dart';
import 'package:declarative_navigation/screen/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/sharedpref_repository.dart';
import '../provider/sharedpref_provider.dart';
import '../provider/stories_provider.dart';
import '../screen/add_story/add_story_screen.dart';
import '../screen/add_story/camera_screen.dart';
import '../screen/auth/login_screen.dart';
import '../screen/detail/story_detail_screen.dart';
import '../screen/home/stories_screen.dart';
import '../screen/others/splash_screen.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey;
  final SharedPrefRepository sharedPerfRepository;

  MyRouterDelegate(
    this.sharedPerfRepository,
  ) : _navigatorKey = GlobalKey<NavigatorState>() {
    _init();
  }

  List<CameraDescription> cameras = [];

  _init() async {
    isLoggedIn = await sharedPerfRepository.isUserLoggedIn();
    notifyListeners();

    try {
      cameras = await availableCameras();
    } catch (e) {
      print("Gagal mendapatkan daftar kamera: $e");
    }
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  String? selectedStory;
  String? customCameraImagePath;
  List<Page> historyStack = [];
  bool? isLoggedIn;
  bool isRegister = false;
  bool isAddingNewStory = false;
  bool isUsingCustomCamera = false;

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      historyStack = _splashStack;
    } else if (isLoggedIn == true) {
      historyStack = _loggedInStack;
    } else {
      historyStack = _loggedOutStack;
    }

    return Navigator(
      key: navigatorKey,
      pages: historyStack,
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) return false;

        if (isUsingCustomCamera) {
          isUsingCustomCamera = false;
        } else if (isAddingNewStory) {
          isAddingNewStory = false;
        } else if (selectedStory != null) {
          selectedStory = null;
        } else if (isRegister) {
          isRegister = false;
        }

        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async {}

  List<Page> get _splashStack => const [
        MaterialPage(
          key: ValueKey("SplashScreen"),
          child: SplashScreen(),
        ),
      ];

  List<Page> get _loggedOutStack => [
        MaterialPage(
          key: const ValueKey("LoginPage"),
          child: LoginScreen(
            onLoginSuccess: () {
              isLoggedIn = true;
              notifyListeners();
            },
            onNavigateToRegister: () {
              isRegister = true;
              notifyListeners();
            },
          ),
        ),
        if (isRegister == true)
          MaterialPage(
            key: const ValueKey("RegisterPage"),
            child: RegisterScreen(
              onRegister: () {
                isRegister = false;
                notifyListeners();
              },
              onLogin: () {
                isRegister = false;
                notifyListeners();
              },
            ),
          ),
      ];

  List<Page> get _loggedInStack => [
        MaterialPage(
          key: const ValueKey("StoriesListPage"),
          child: StoriesScreen(
            onTapped: (String storyId) {
              selectedStory = storyId;
              notifyListeners();
            },
            onLogout: () {
              isLoggedIn = false;
              notifyListeners();
            },
            onAddNewStory: () {
              isAddingNewStory = true;
              notifyListeners();
            },
          ),
        ),
        if (selectedStory != null)
          MaterialPage(
            key: ValueKey(selectedStory),
            child: DetailScreen(
              storyId: selectedStory!,
            ),
          ),
        if (isAddingNewStory)
          MaterialPage(
            key: const ValueKey("AddNewStoryPage"),
            child: AddNewStoryScreen(
              onStoryAdded: () {
                isAddingNewStory = false;
                notifyListeners();
              },
              onCustomCamera: () {
                isUsingCustomCamera = true;
                notifyListeners();
              },
              onRefreshStories: () async {
                // Gunakan navigatorKey untuk mendapatkan context
                final currentContext = navigatorKey.currentContext;
                if (currentContext != null) {
                  final sharedPrefProvider =
                      currentContext.read<SharedPrefProvider>();
                  final userToken = await sharedPrefProvider.getUserToken();

                  if (userToken?.token != null) {
                    currentContext
                        .read<StoriesProvider>()
                        .fetchStories(userToken!.token!);
                  }
                }
              },
              customImagePath: customCameraImagePath,
            ),
          ),
        if (isUsingCustomCamera)
          MaterialPage(
            key: const ValueKey("CustomCameraPage"),
            child: CameraScreen(
              cameras: cameras,
              onCapture: (String imagePath) {
                customCameraImagePath = imagePath;
                isUsingCustomCamera = false;
                isAddingNewStory = true;
                notifyListeners();
              },
            ),
          ),
      ];
}
