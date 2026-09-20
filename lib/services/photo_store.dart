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
/// 썸네일을 만들 때 사진 검색용 지각 해시(dHash)도 같이 계산한다.
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

  /// 포토 피커를 열어 여러 장 선택 → 저장. (file, thumb, hash) 목록을 반환.
  /// 사용자가 취소하면 빈 목록.
  Future<List<({String file, String thumb, int hash})>> pickAndSave() async {
    final picked = await _picker.pickMultiImage(
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    final out = <({String file, String thumb, int hash})>[];
    for (final x in picked) {
      try {
        out.add(await _save(x));
      } catch (e) {
        debugPrint('photo save failed: $e');
      }
    }
    return out;
  }

  /// 검색용으로 사진 1장을 골라 해시만 계산한다 (앱에 저장하지 않음). 취소면 null.
  Future<int?> pickForSearch() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: thumbSide * 2,
      maxHeight: thumbSide * 2,
    );
    if (x == null) return null;
    return hashOfFile(File(x.path));
  }

  /// 파일(JPEG 등)의 dHash. 썸네일과 같은 방식(중앙 정방형 crop)으로 계산한다.
  Future<int> hashOfFile(File f) async {
    final rgba = await _decodeSquare(await f.readAsBytes());
    return compute(_hashRgba, rgba);
  }

  Future<({String file, String thumb, int hash})> _save(XFile x) async {
    final name = '${DateTime.now().microsecondsSinceEpoch}_${_counter++}.jpg';
    final relFile = p.join('photos', name);
    final relThumb = p.join('thumbs', name);
    final dst = fileOf(relFile);
    await File(x.path).copy(dst.path);
    final rgba = await _decodeSquare(await dst.readAsBytes());
    final r = await compute(_encodeJpgAndHash, rgba);
    await fileOf(relThumb).writeAsBytes(r.jpg);
    return (file: relFile, thumb: relThumb, hash: r.hash);
  }

  /// 엔진의 네이티브 디코더(dart:ui)로 축소 디코딩 + 중앙 crop → 320×320 RGBA.
  /// 순수 Dart 디코딩보다 훨씬 빠르고 EXIF 회전도 엔진이 처리한다.
  Future<Uint8List> _decodeSquare(Uint8List bytes) async {
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
    return raw!.buffer.asUint8List();
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

  /// 두 해시의 해밍 거리 (0 = 같음, 64 = 완전히 다름). 10 이하면 같은 사진으로 본다.
  static int hammingDistance(int a, int b) {
    var x = a ^ b;
    var n = 0;
    while (x != 0) {
      x &= x - 1;
      n++;
    }
    return n;
  }

  static const similarThreshold = 10;
}

img.Image _fromRgba(Uint8List rgba) => img.Image.fromBytes(
  width: PhotoStore.thumbSide,
  height: PhotoStore.thumbSide,
  bytes: rgba.buffer,
  numChannels: 4,
  order: img.ChannelOrder.rgba,
);

/// dHash: 9×8 회색조로 줄인 뒤 가로 이웃 픽셀의 밝기 차 부호 64개.
int _dHash(img.Image im) {
  final g = img.grayscale(
    img.copyResize(
      im,
      width: 9,
      height: 8,
      interpolation: img.Interpolation.average,
    ),
  );
  var h = 0;
  for (var y = 0; y < 8; y++) {
    for (var x = 0; x < 8; x++) {
      final l = g.getPixel(x, y).r;
      final r = g.getPixel(x + 1, y).r;
      h = (h << 1) | (l > r ? 1 : 0);
    }
  }
  return h;
}

/// 별도 isolate: RGBA(320×320) → JPEG + dHash.
({Uint8List jpg, int hash}) _encodeJpgAndHash(Uint8List rgba) {
  final im = _fromRgba(rgba);
  return (jpg: img.encodeJpg(im, quality: 80), hash: _dHash(im));
}

int _hashRgba(Uint8List rgba) => _dHash(_fromRgba(rgba));
