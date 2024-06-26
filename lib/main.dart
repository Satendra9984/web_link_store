import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:web_link_store/app_screens/home_screen.dart';
import 'package:web_link_store/app_services/databases/database_constants.dart';
import 'package:web_link_store/app_models/link_tree_folder_model.dart';
import 'app_themes/custom_light_theme.dart';

/// Before you can use the hive, you need to initialize it.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Directory directory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(directory.path);

  /// register typeAdapters
  Hive.registerAdapter(LinkTreeFolderAdapter());

  /// opening hive box for all nested_folders and url's
  /// of type LinkTreeAdapter
  await Hive.openBox<LinkTreeFolder>(kLinkTreeBox);
  await Hive.openBox(kRecentLinkTreeFolders);
  await Hive.openBox(kRecentLinks);

  await Hive.openBox(kFavouriteLinkTreeFolders);
  await Hive.openBox(kFavouriteLinks);

  /// running the app
  runApp(
    const ProviderScope(

      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      // theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.white)),
      // darkTheme: AppTheme.dartTheme,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
    );
  }
}
