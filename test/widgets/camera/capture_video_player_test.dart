import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/widgets/camera/capture_video_player.dart';

void main() {
  testWidgets('CaptureVideoPlayer renders initial placeholder and play button', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CaptureVideoPlayer(videoUrl: 'https://example.com/video.mp4'),
        ),
      ),
    );

    expect(find.byIcon(Icons.videocam_rounded), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });
}

