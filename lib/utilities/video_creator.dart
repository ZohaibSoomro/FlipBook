import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:media_scanner/media_scanner.dart';

class VideoCreator {
  Future<bool> createVideo(List<String> images, String baseDir,
      String outputFileName, int frameRate) async {
    int width = 1280;
    int height = 720;
    int fps = frameRate;
    final extension = images.first.substring(images.first.lastIndexOf('.') + 1);
    print("Extension: $extension, first image: ${images.first}");
    print("basedir: $baseDir");

    final String command = "-y "
        "-framerate $fps "
        "-f image2 "
        "-s ${width}x$height "
        "-start_number 001 "
        "-i ${"$baseDir/image_%03d.$extension"} "
        // "-i ${baseDir}image%03d.png "
        "-vf scale=-2:588 "
        "-vcodec libx264 "
        "-crf 25 "
        "-b:v 1500k  "
        "-pix_fmt yuv420p "
        "-v error "
        "$outputFileName";

    final FFmpegSession response = await FFmpegKit.execute(command);
    print("Logs: ");
    (await response.getLogs()).forEach((element) {
      print("Log: ${element.getMessage()}");
    });

    if (ReturnCode.isSuccess(await response.getReturnCode())) {
      print('Video created successfully at $outputFileName');

      await MediaScanner.loadMedia(path: outputFileName);
      return true;
    } else {
      print('Error creating video: ${await response.getFailStackTrace()}');
      print('Video creation failed!');
      return false;
    }
  }
}
