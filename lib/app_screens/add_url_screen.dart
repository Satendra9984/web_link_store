import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_link_store/app_services/url_parsing/fetch_preview_details.dart';
import '../app_services/databases/hive_database.dart';
import '../app_models/link_tree_folder_model.dart';
import '../app_widgets/text_input.dart';
import '../constants.dart';

class AddUrlScreen extends StatefulWidget {
  final String rootFolderKey;
  final String? sharedUrl;
  const AddUrlScreen({
    Key? key,
    required this.rootFolderKey,
    this.sharedUrl,
  }) : super(key: key);

  @override
  State<AddUrlScreen> createState() => _AddUrlScreenState();
}

class _AddUrlScreenState extends State<AddUrlScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false, _favourite = false;
  String url = '', urlTitle = '';
  String? desc = '';

  Future<void> saveUrl() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      LinkTreeFolder linkTree =
          HiveService().getTreeData(widget.rootFolderKey)!;
      final HiveService hiveService = HiveService();
      final FetchPreviewDetails fetchPreviewDetails = FetchPreviewDetails();
      Map<String, dynamic> idata = await fetchPreviewDetails.fetch(url);
      idata['url_title'] = urlTitle;
      idata['user_note'] = desc ?? '';
      idata['url'] = url;
      idata['is_favourite'] = _favourite;
      /*
      {
      'url' : url,
      'favicon': faviconUint,
      'image': imageUint,
      'image_title': title ?? 'No title available',
      'description': description ?? 'No description available',
      'size': {
        'height': desc['height'] ?? 0,
        'width': desc['width'] ?? 0,
      },
    };
    */
      /// get list of url
      List<Map<String, dynamic>> listUrl = linkTree.urls;

      /// add idata to the list
      listUrl.insert(listUrl.length, idata);

      LinkTreeFolder? parentFolder =
          hiveService.getTreeData(widget.rootFolderKey);

      if (parentFolder == null) return;
      hiveService.update(
        LinkTreeFolder(
          id: linkTree.id,
          parentFolderId: parentFolder.id,
          description: linkTree.description,
          isFavourite: linkTree.isFavourite,
          category: linkTree.category,
          subFolders: linkTree.subFolders,
          urls: listUrl,
          folderName: linkTree.folderName,
        ),
      );
      if (_favourite) {
        await hiveService.addFavouriteLinks(idata);
      }

      /// update linktree
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.sharedUrl != null) {
      url = widget.sharedUrl!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Url',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          _isSaving
              ? Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.green.shade800,
                  ),
                )
              : IconButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isSaving = true;
                      });

                      try {
                        await saveUrl();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: Center(child: Text('Saved')),
                          ),
                        );
                      } catch (e) {
                        debugPrint('[log][error] : $e');
                        setState(() {
                          _isSaving = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Center(
                              child: Text(
                                'Something Went wrong.',
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check),
                ),
        ],
        // elevation: 0,
        // backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextInput(
                  label: 'URL',
                  formField: TextFormField(
                    initialValue: url,
                    onChanged: (value) {
                      url = value;
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 2,
                    cursorHeight: 30,
                    cursorWidth: 2.5,
                                        cursorColor: const Color(0xff3cac7c),

                    decoration: kInputDecoration.copyWith(
                      hintText: 'https://google.com',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a url';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20.0),

                TextInput(
                  label: 'TITLE',
                  formField: TextFormField(
                    onChanged: (value) {
                      urlTitle = value;
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 2,
                    cursorHeight: 30,
                    cursorWidth: 2.5,
                                        cursorColor: const Color(0xff3cac7c),

                    decoration: kInputDecoration.copyWith(
                      hintText: 'title',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20.0),

                // IS fAVOURITE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Favourite',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch.adaptive(
                      value: _favourite,
                      onChanged: (value) => setState(() {
                        _favourite = !_favourite;
                      }),
                      activeColor: Colors.green,
                      inactiveTrackColor: Colors.red,
                    ),
                  ],
                ),

                const SizedBox(height: 20.0),

                TextInput(
                  label: 'Add Note',
                  formField: TextFormField(
                    onChanged: (value) {
                      desc = value;
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 3,
                    cursorHeight: 30,
                    cursorWidth: 2.5,
                                        cursorColor: const Color(0xff3cac7c),

                    decoration: kInputDecoration.copyWith(
                      hintText: 'save your important details here',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    validator: (value) {
                      return null;
                    },
                  ),
                ),

                /// todo : add preview
                const SizedBox(height: 20),
                // const Text(
                //     'TODO: Add url name\nTODO: Add insert at variable field\n todo : add preview show\n'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
