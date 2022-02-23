import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailViewer extends StatelessWidget {
  final videoFile;
  final videoDuration;
  final thumbnailHeight;
  final fit;
  final int numberOfThumbnails;
  final int quality;
  final Function onThumbnailsGenerated;

  /// For showing the thumbnails generated from the video,
  /// like a frame by frame preview
  ThumbnailViewer({
    Key? key,
    required this.videoFile,
    required this.videoDuration,
    required this.thumbnailHeight,
    required this.numberOfThumbnails,
    required this.fit,
    required this.onThumbnailsGenerated,
    this.quality = 75,
  }) : super(key: key);

  Stream<List<Uint8List>> generateThumbnail() async* {
    final String _videoPath = videoFile.path;

    double _eachPart = videoDuration / numberOfThumbnails;

    List<Uint8List> _byteList = [];

    for (int i = 1; i <= numberOfThumbnails; i++) {
      Uint8List? _bytes;
      try {
        _bytes = await VideoThumbnail.thumbnailData(
          video: _videoPath,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 128,
          timeMs: (_eachPart * i).toInt(),
          quality: quality,
        );
      } catch (_) {}
      if (_bytes != null) _byteList.add(_bytes);

      yield _byteList;
    }

    onThumbnailsGenerated();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: generateThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Uint8List>? _imageBytes = snapshot.data as List<Uint8List>;
          return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imageBytes.length,
              itemBuilder: (context, index) {
                var imageBytes = _imageBytes[index];

                if (imageBytes == null && index > 0) {
                  imageBytes = _imageBytes[index - 1];
                }

                return Container(
                  height: thumbnailHeight,
                  width: thumbnailHeight,
                  child: imageBytes == null
                      ? Container()
                      : Image(
                          image: MemoryImage(imageBytes),
                          fit: fit,
                        ),
                );
              });
        } else {
          return Container(
            color: Colors.grey[900],
            height: thumbnailHeight,
            width: double.maxFinite,
          );
        }
      },
    );
  }
}
