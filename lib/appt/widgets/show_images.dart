import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../../common/responsiveness.dart';

class ShowImages extends StatelessWidget {
  const ShowImages(
    this.urlList, {
    super.key,
    // this.minimised = false
  });
  final List<String> urlList;
  // final bool minimised;

  @override
  Widget build(BuildContext context) {
    print(ResponsiveWidget.isLargeScreen(context));
    return GridView.builder(
      padding: EdgeInsets.only(
          right: MediaQuery.of(context).size.width *
              (ResponsiveWidget.isLargeScreen(context) ||
                      ResponsiveWidget.isMediumScreen(context)
                  ? 0
                  : 0.35)),
      shrinkWrap: true,
      itemCount: urlList.length,
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
                barrierLabel:
                    MaterialLocalizations.of(context).modalBarrierDismissLabel,
                pageBuilder: (_, __, ___) => ImageDialog(url: urlList[index]));
          },
          child: CachedNetworkImage(
            imageUrl: urlList[index],
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          ),
          // Image.network(urlList[index], fit: BoxFit.cover),
        );
      },
    );
  }
}

// hao xiang meiyou semo yong
// minimised
//   ?
//   SizedBox(
//       height: 50,
//       width: 50,
//       child: Image.network(urlList[index], fit: BoxFit.cover),
//     )
//   :

class ImageDialog extends StatelessWidget {
  final String url;

  const ImageDialog({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    // final double screenHeight = MediaQuery.of(context).size.height;
    // final double width = MediaQuery.of(context).size.width;

    Image image = Image.network(url);
    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    }));
    // image.image
    //   .resolve(const ImageConfiguration())
    //   .addListener(ImageStreamListener((ImageInfo info, bool _) {
    //     completer.complete(info.image));

    return FutureBuilder<ui.Image>(
      future: completer.future,
      builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
        if (snapshot.hasData) {
          // bool picPortrait = snapshot.data!.height > snapshot.data!.width;
          // bool screenPortrait = MediaQuery.of(context).size.height >
          //     MediaQuery.of(context).size.width;
          Map<String, dynamic> ghaw = getHeightAndWith(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
              snapshot.data!.width,
              snapshot.data!.height);
          return Center(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white)),
              child: InteractiveViewer(
                constrained: true,
                maxScale: 5.0,
                minScale: 0.5,
                child: CachedNetworkImage(
                  imageUrl: url,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                  height: ghaw['height'],
                  width: ghaw['width'],
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Map<String, dynamic> getHeightAndWith(
      double sWidth, double sHeight, int pWidth, int pHeight) {
    bool sPort = sHeight > sWidth;
    bool pPort = pHeight > pWidth;
    if (pWidth == pHeight) {
      // this should get the shorter end of screen
      if (sWidth == sHeight || sPort) {
        return {'height': 0.8 * sHeight, 'width': null};
      } else {
        // meaning sLand
        return {'height': null, 'width': 0.8 * sWidth};
      }
    } else if (sPort && pPort) {
      //screen port & pic port
      return {'height': 0.8 * sHeight, 'width': null};
    } else if (sPort && !pPort) {
      //screen port & pic land
      return {'height': null, 'width': 1.0 * sWidth};
    } else if (!sPort && pPort) {
      //screen land & pic port
      return {'height': 1.0 * sHeight, 'width': null};
    } else if (!sPort && !pPort) {
      //screen land & pic land
      return {'height': null, 'width': 0.8 * sWidth};
    } else {
      return {'height': 0.8 * sHeight, 'width': null};
    }
  }
}
