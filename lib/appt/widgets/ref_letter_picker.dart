import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/common/firebase/firebase_const.dart';
import 'dart:math';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class RefLetterPicker extends StatefulWidget {
  const RefLetterPicker(this.imageFn, {super.key});
  final void Function(List<XFile> pickedImage) imageFn;

  @override
  // ignore: library_private_types_in_public_api
  _RefLetterPickerState createState() => _RefLetterPickerState();
}

class _RefLetterPickerState extends State<RefLetterPicker> {
  List<File> _pickedImageFile = []; // File('');
  List<XFile> xFileList = [];
  final picker = ImagePicker();
  final ValueNotifier<List<File>> _picFiles = ValueNotifier<List<File>>([]);
  // String random = getRandomString(5);

  void _pickImage() async {
    FocusScope.of(context).unfocus();    
    List<XFile> picked = await picker.pickMultiImage(
        // all these max, try out first - without them clearer image but need good wifi
        // maxHeight: 480,
        // maxWidth: 640,
        imageQuality: 100);
    if (picked.length > 3) picked = picked.sublist(0, 3);
    for (var image in picked) {
      if (xFileList.length >= 3) xFileList = xFileList.sublist(1, 3);
      xFileList.add(image);
      if (_pickedImageFile.length >= 3) {
        _pickedImageFile = _pickedImageFile.sublist(1, 3);
      }
      _pickedImageFile.add(File(image.path));
    }
    _picFiles.value = _pickedImageFile;
    // final pickedImageFile = File(pickedImage!.path);

    // setState(() {
    //   _pickedImageFile = pickedImageFile;
    // });

    widget.imageFn(xFileList);
    setState(() {}); // apparently need this
    // random = getRandomString(5); // this dont work
  }

  void _takePicture() async {
    FocusScope.of(context).unfocus();
    XFile? picked = await picker.pickImage(
        source: ImageSource.camera,
        // maxHeight: 480,
        // maxWidth: 640,
        imageQuality: 50);
    if (xFileList.length >= 3) xFileList = xFileList.sublist(1, 3);
    xFileList.add(picked!);
    if (_pickedImageFile.length >= 3) {
      _pickedImageFile = _pickedImageFile.sublist(1, 3);
    }
    _pickedImageFile.add(File(picked.path));
    // final pickedImageFile = File(pickedImage!.path);

    // setState(() {
    //   _pickedImageFile = pickedImageFile;
    // });
    _picFiles.value = _pickedImageFile;
    widget.imageFn(xFileList);
    setState(() {}); // apparently need this
    // random = getRandomString(5); // this dont work
  }

  ImageProvider<Object> justReturnImage(File ff) {
    if (kIsWeb) {
      return NetworkImage(ff.path);
    } else {
      return FileImage(ff);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text('Upload Referral Letter (3 Max):'),
            IconButton(
              onPressed: _pickImage,
              icon: const Icon(
                Icons.image,
              ),
            ),
            (isWebMobile || isApp) // why only webMobile?
                ? IconButton(
                    onPressed: _takePicture,
                    icon: const Icon(
                      Icons.camera_alt,
                    ),
                  )
                : Container(),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        // _pickedImageFile.path.isEmpty
        //     ? Container()
        //     : ConstrainedBox(
        //         constraints: const BoxConstraints(maxWidth: 500),
        //         child: Image(
        //           image: justReturnImage(),
        //         ),
        //       ),
        ValueListenableBuilder<List<File>>(
          valueListenable: _picFiles,
          builder: (context, value, _) {
            return GridView.builder(
              // key: Key(random),
              shrinkWrap: true,
              itemCount: value.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    await showGeneralDialog(
                        context: context,
                        barrierColor: Colors.black87,
                        barrierDismissible: true,
                        barrierLabel: MaterialLocalizations.of(context)
                            .modalBarrierDismissLabel,
                        pageBuilder: (_, __, ___) =>
                            ImageDialog(lll: value[index]));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: justReturnImage(value[index]),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class ImageDialog extends StatelessWidget {
  final File lll;

  const ImageDialog({super.key, required this.lll});

  ImageProvider<Object> justReturnImage(File ff) {
    if (kIsWeb) {
      return NetworkImage(ff.path);
    } else {
      return FileImage(ff);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return
        // SizedBox.expand( // if use this cant use barrierdismissable
        //   child:
        Center(
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(width: 2, color: Colors.white)),
        child: InteractiveViewer(
          constrained: true,
          maxScale: 5.0,
          minScale: 0.5,
          // boundaryMargin: EdgeInsets.all(5.0),
          child: Image(
            image: justReturnImage(lll),
            fit: BoxFit.cover,
            height: height * 0.8,
          ),
        ),
        // ),
      ),
    )
        // Center(
        //   child: Image(
        //     image: justReturnImage(lll),
        //     fit: BoxFit.cover,
        //     height: height,
        //   ),
        // )
        ;
  }
}
