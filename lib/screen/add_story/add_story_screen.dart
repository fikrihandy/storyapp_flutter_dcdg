import 'dart:io';
import 'package:declarative_navigation/screen/others/snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../provider/image_provider.dart';
import '../../provider/sharedpref_provider.dart';
import '../../provider/upload_provider.dart';
import '../../static/strings.dart';

class AddNewStoryScreen extends StatefulWidget {
  final Function() onStoryAdded;
  final Function() onCustomCamera;
  final Function() onRefreshStories;
  final String? customImagePath;

  const AddNewStoryScreen({
    super.key,
    required this.onStoryAdded,
    required this.onCustomCamera,
    required this.onRefreshStories,
    this.customImagePath,
  });

  @override
  State<AddNewStoryScreen> createState() => _AddNewStoryScreenState();
}

class _AddNewStoryScreenState extends State<AddNewStoryScreen> {
  String _imageDescription = '';

  @override
  void didUpdateWidget(covariant AddNewStoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customImagePath != null &&
        widget.customImagePath != oldWidget.customImagePath) {
      final imgProvider = context.read<ImgProvider>();
      imgProvider.setImagePath(widget.customImagePath);

      final imageFile = XFile(widget.customImagePath!);
      imgProvider.setImageFile(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(addStoryPage),
        actions: [
          IconButton(
            onPressed: () => _onUpload(),
            icon: context.watch<UploadProvider>().isUploading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Icon(Icons.upload),
            tooltip: "Upload",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: context.watch<ImgProvider>().imagePath == null
                  ? const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image,
                        size: 100,
                      ),
                    )
                  : _showImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _imageDescription = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: description,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _onGalleryView(),
                    child: const Text(gallery),
                  ),
                  ElevatedButton(
                    onPressed: () => _onCameraView(),
                    child: const Text(camera),
                  ),
                  ElevatedButton(
                    onPressed: () => _onCustomCameraView(),
                    child: const Text(customCam),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _onUpload() async {
    final uploadProvider = context.read<UploadProvider>();
    final imgProvider = context.read<ImgProvider>();
    final sharedPrefProvider = context.read<SharedPrefProvider>();

    final imagePath = imgProvider.imagePath;
    final imageFile = imgProvider.imageFile;

    if (imagePath == null || imageFile == null) {
      showSnackBar(context, noImageSelected);
      return;
    }

    final userToken = await sharedPrefProvider.getUserToken();

    if (userToken == null || userToken.token == "") {
      showSnackBar(context, authTokenNotFound);
      return;
    }

    try {
      final fileName = imageFile.name;
      final bytes = await imageFile.readAsBytes();

      final newBytes = await uploadProvider.compressImage(bytes);

      await uploadProvider.upload(
        newBytes,
        fileName,
        _imageDescription,
        userToken.token ?? "",
      );

      final uploadResponse = uploadProvider.uploadResponse;
      if (uploadResponse != null) {
        imgProvider.setImageFile(null);
        imgProvider.setImagePath(null);

        if (!uploadResponse.error) {
          widget.onRefreshStories(); // Panggil refresh setelah berhasil upload
          widget.onStoryAdded();
        }
      }
      showSnackBar(context, uploadProvider.message);
    } catch (e) {
      showSnackBar(context, "Error during upload: $e");
    }
  }


  _onGalleryView() async {
    final provider = context.read<ImgProvider>();

    final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    final isLinux = defaultTargetPlatform == TargetPlatform.linux;
    if (isMacOS || isLinux) return;

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  _onCameraView() async {
    final provider = context.read<ImgProvider>();

    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isiOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isNotMobile = !(isAndroid || isiOS);
    if (isNotMobile) return;

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  _onCustomCameraView() {
    widget.onCustomCamera();
  }

  Widget _showImage() {
    final imagePath = context.read<ImgProvider>().imagePath;
    return kIsWeb
        ? Image.network(
            imagePath.toString(),
            fit: BoxFit.contain,
          )
        : Image.file(
            File(imagePath.toString()),
            fit: BoxFit.contain,
          );
  }
}
