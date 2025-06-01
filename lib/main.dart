import 'package:declarative_navigation/data/api/api_services.dart';
import 'package:declarative_navigation/db/sharedpref_repository.dart';
import 'package:declarative_navigation/provider/image_provider.dart';
import 'package:declarative_navigation/provider/story_provider.dart';
import 'package:declarative_navigation/provider/sharedpref_provider.dart';
import 'package:declarative_navigation/provider/login_provider.dart';
import 'package:declarative_navigation/provider/register_provider.dart';
import 'package:declarative_navigation/provider/stories_provider.dart';
import 'package:declarative_navigation/provider/upload_provider.dart';
import 'package:declarative_navigation/routes/router_delegate.dart';
import 'package:declarative_navigation/static/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const StoryApp());
}

class StoryApp extends StatefulWidget {
  const StoryApp({super.key});

  @override
  State<StoryApp> createState() => _StoryAppState();
}

class _StoryAppState extends State<StoryApp> {
  late MyRouterDelegate myRouterDelegate;
  late SharedPrefProvider authProvider;

  @override
  void initState() {
    super.initState();
    final authRepository = SharedPrefRepository();
    authProvider = SharedPrefProvider(authRepository);
    myRouterDelegate = MyRouterDelegate(authRepository);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => ApiServices(),
        ),
        ChangeNotifierProvider(
          create: (context) => authProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => RegisterProvider(
            context.read<ApiServices>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginProvider(
            context.read<ApiServices>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => StoriesProvider(
            context.read<ApiServices>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => StoryProvider(
            context.read<ApiServices>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ImgProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UploadProvider(
            ApiServices(),
          ),
        ),
      ],
      child: MaterialApp(
        title: storiesPage,
        home: Router(
          routerDelegate: myRouterDelegate,
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
      ),
    );
  }
}
