import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_vault/app_models/link_tree_folder_model.dart';
import 'package:link_vault/app_providers/receive_text.dart';
import 'package:link_vault/app_screens/dashboard.dart';
import 'package:link_vault/app_screens/store_screen.dart';
import 'package:link_vault/app_services/databases/database_constants.dart';
import 'package:link_vault/app_services/databases/hive_database.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late StreamSubscription _intentDataStreamSubscription;
  late final PageController _pageController;
  int _currentIndex = 0;
  LinkTreeFolder _getBaseTree() {
    final hiveService = HiveService();
    var baseFolder = hiveService.getTreeData(kRootDirectory);

    if (baseFolder != null) {
      return baseFolder;
    }
    hiveService.add(
      LinkTreeFolder(
        id: kRootDirectory,
        parentFolderId: '${kRootDirectory}Parent',
        subFolders: [],
        urls: [],
        folderName: 'link_vault',
      ),
    );

    baseFolder = hiveService.getTreeData(kRootDirectory);
    return baseFolder!;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _intentDataStreamSubscription =

        /// This is used when app is running
        ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      final rec = ref.read(receiveTextProvider.notifier);

      for (final file in value) {
        if (file.type == SharedMediaType.text) {
          if (value.isNotEmpty) {
            rec.changeState(true, file.path);
          } else {
            rec.changeState(false, '');
          }
        }
      }
    });

    /// This stream is used when app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      final rec = ref.read(receiveTextProvider.notifier);

      for (final file in value) {
        if (file.type == SharedMediaType.text) {
          if (value.isNotEmpty) {
            rec.changeState(true, file.path);
          } else {
            rec.changeState(false, '');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Material(
        elevation: 8,
        shadowColor: Colors.grey.shade800,
        child: BottomNavigationBar(
          elevation: 4,
          currentIndex: _currentIndex,
          onTap: (currentPage) {
            _pageController.jumpToPage(currentPage);
            setState(() {
              _currentIndex = currentPage;
            });
          },
          selectedItemColor: const Color(0xff3cac7c),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.line_style_rounded,
              ),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.dashboard,
              ),
              label: 'Utils',
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() {
          _currentIndex = index;
        }),
        children: [
          StorePage(parentFolderId: _getBaseTree().id),
          const DashboardScreen(),
        ],
      ),
    );
  }
}
