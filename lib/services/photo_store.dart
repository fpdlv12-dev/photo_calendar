import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 사진 파일 관리. 시스템 포토 피커로 고른 사진을 앱 문서 폴더에 복사하고
/// (긴 변 1600px 로 축소), 월 화면용 정방형 썸네일(320px)을 따로 만든다.
///
/// DB 에는 문서 폴더 기준 상대 경로만 저장한다 (기기 복원 시 절대 경로가 바뀔 수 있음).
class PhotoStore {
  static const thumbSide = 320;

  late final Directory _root;
  final _picker = ImagePicker();
  static int _counter = 0;

  Future<void> init() async {
    _root = await getApplicationDocumentsDirectory();
    await Directory(p.join(_root.path, 'photos')).create(recursive: true);
    await Directory(p.join(_root.path, 'thumbs')).create(recursive: true);
  }

  File fileOf(String relative) => File(p.join(_root.path, relative));

  /// 포토 피커를 열어 여러 장 선택 → 저장. (file, thumb) 상대 경로 쌍 목록을 반환.
  /// 사용자가 취소하면 빈 목록.
  Future<List<({String file, String thumb})>> pickAndSave() async {
    final picked = await _picker.pickMultiImage(
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    final out = <({String file, String thumb})>[];
    for (final x in picked) {
      try {
        out.add(await _save(x));
      } catch (e) {
        debugPrint('photo save failed: $e');
      }
    }
    return out;
  }

  Future<({String file, String thumb})> _save(XFile x) async {
    final name = '${DateTime.now().microsecondsSinceEpoch}_${_counter++}.jpg';
    final relFile = p.join('photos', name);
    final relThumb = p.join('thumbs', name);
    final dst = fileOf(relFile);
    await File(x.path).copy(dst.path);
    await _makeThumb(dst, fileOf(relThumb));
    return (file: relFile, thumb: relThumb);
  }

  /// 엔진의 네이티브 디코더(dart:ui)로 축소 디코딩 + 중앙 crop 한 뒤,
  /// JPEG 인코딩만 별도 isolate 에서 한다. 순수 Dart 디코딩보다 훨씬 빠르고
  /// EXIF 회전도 엔진이 처리한다.
  Future<void> _makeThumb(File src, File dst) async {
    final bytes = await src.readAsBytes();
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final desc = await ui.ImageDescriptor.encoded(buffer);
    final scale = thumbSide / math.min(desc.width, desc.height);
    final codec = await desc.instantiateCodec(
      targetWidth: math.max(thumbSide, (desc.width * scale).round()),
      targetHeight: math.max(thumbSide, (desc.height * scale).round()),
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final sw = image.width.toDouble(), sh = image.height.toDouble();
    final s = math.min(sw, sh);
    final rec = ui.PictureRecorder();
    final canvas = ui.Canvas(rec);
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH((sw - s) / 2, (sh - s) / 2, s, s),
      ui.Rect.fromLTWH(0, 0, thumbSide.toDouble(), thumbSide.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
    final out = await rec.endRecording().toImage(thumbSide, thumbSide);
    final raw = await out.toByteData(format: ui.ImageByteFormat.rawRgba);

    image.dispose();
    out.dispose();
    codec.dispose();
    desc.dispose();
    buffer.dispose();

    final jpg = await compute(_encodeJpg, raw!.buffer.asUint8List());
    await dst.writeAsBytes(jpg);
  }

  Future<void> deleteFiles(String? file, String? thumb) async {
    for (final r in [file, thumb]) {
      if (r == null) continue;
      try {
        final f = fileOf(r);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }
}

/// 별도 isolate: RGBA(320×320) → JPEG.
Uint8List _encodeJpg(Uint8List rgba) {
  final im = img.Image.fromBytes(
    width: PhotoStore.thumbSide,
    height: PhotoStore.thumbSide,
    bytes: rgba.buffer,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );
  return img.encodeJpg(im, quality: 80);
}
