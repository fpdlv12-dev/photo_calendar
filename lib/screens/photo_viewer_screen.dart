import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../l10n/app_localizations.dart';
import '../models/entry.dart';
import '../util/dates.dart';

/// 사진 전체 화면 보기. 좌우 스와이프, 핀치 줌, 삭제, 다른 날짜로 이동.
class PhotoViewerScreen extends StatefulWidget {
  final List<Entry> photos;
  final int initialIndex;
  const PhotoViewerScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late final List<Entry> _photos = List.of(widget.photos);
  late final PageController _page = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;
  bool _chrome = true;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final t = L10n.of(context);
    final store = AppScope.of(context).store;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteConfirmTitle),
        content: Text(t.deletePhotoConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final e = _photos[_index];
    await store.remove(e);
    if (!mounted) return;
    setState(() {
      _photos.removeAt(_index);
      if (_index >= _photos.length) _index = _photos.length - 1;
    });
    if (_photos.isEmpty) Navigator.of(context).pop();
  }

  Future<void> _move() async {
    final store = AppScope.of(context).store;
    final e = _photos[_index];
    final cur = parseDateKey(e.date);
    final picked = await showDatePicker(
      context: context,
      initialDate: cur,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted || sameDay(picked, cur)) return;
    await store.update(e.copyWith(date: dateKey(picked)), oldDate: e.date);
    if (!mounted) return;
    setState(() {
      _photos.removeAt(_index);
      if (_index >= _photos.length) _index = _photos.length - 1;
    });
    if (_photos.isEmpty) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final fileOf = AppScope.of(context).store.photos.fileOf;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: _chrome
            ? AppBar(
                backgroundColor: Colors.black45,
                foregroundColor: Colors.white,
                title: Text('${_index + 1} / ${_photos.length}'),
                actions: [
                  IconButton(
                    tooltip: t.movePhotoTo,
                    icon: const Icon(Icons.drive_file_move_outline),
                    onPressed: _move,
                  ),
                  IconButton(
                    tooltip: t.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _delete,
                  ),
                ],
              )
            : null,
        body: GestureDetector(
          onTap: () => setState(() => _chrome = !_chrome),
          child: PageView.builder(
            controller: _page,
            itemCount: _photos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final e = _photos[i];
              return InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Image.file(
                    fileOf(e.file!),
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
