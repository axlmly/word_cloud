import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:word_cloud/word_cloud_data.dart';
import 'package:word_cloud/word_cloud_setting.dart';
import 'package:word_cloud/word_cloud_shape.dart';

Future<Uint8List> exportWordCloudToPng({
  required WordCloudData data,
  required double width,
  required double height,
  required double minTextSize,
  required double maxTextSize,
  List<Color>? colorlist,
  double ratio = 1.0,
}) async {
  final setting = WordCloudSetting(
    data: data.getData(),
    minTextSize: minTextSize,
    maxTextSize: maxTextSize,
    attempt: 30,
    shape: WordCloudShape(),
  );

  setting.setMapSize(width, height);
  setting.setColorList(colorlist);
  setting.setInitial();
  setting.drawTextOptimized();

  final pw = (width * ratio).ceil();
  final ph = (height * ratio).ceil();

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(ratio, ratio);

  for (var i = 0; i < setting.getDataLength(); i++) {
    if (setting.isdrawed[i]) {
      setting.getTextPainter()[i].paint(
        canvas,
        Offset(
          setting.getWordPoint()[i][0].toDouble(),
          setting.getWordPoint()[i][1].toDouble(),
        ),
      );
    }
  }

  final picture = recorder.endRecording();
  final img = await picture.toImage(pw, ph);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
