import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_scope.dart';
import '../l10n/app_localizations.dart';
import '../services/calendar_store.dart';
import '../util/dates.dart';
import '../util/entry_colors.dart';
import '../widgets/banner_ad_widget.dart';
import 'day_screen.dart';

/// 검색: 키워드 또는 사진으로. 결과마다 날짜 · 발췌 · 사진(맞은 사진 앞뒤 1장).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _q = TextEditingController();
  List<SearchHit>? _hits;
  bool _busy = false;
  bool _photoMode = false;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _searchText() async {
    final q = _q.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    final store = AppScope.of(context).store;
    setState(() => _busy = true);
    final hits = await store.searchText(q);
    if (!mounted) return;
    setState(() {
      _hits = hits;
      _photoMode = false;
      _busy = false;
    });
  }

  Future<void> _searchPhoto() async {
    final store = AppScope.of(context).store;
    setState(() => _busy = true);
    try {
      final hash = await store.photos.pickForSearch();
      if (hash == null) return;
      final hits = await store.searchPhoto(hash);
      if (!mounted) return;
      setState(() {
        _hits = hits;
        _photoMode = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final cs = Theme.of(context).colorScheme;
    final hits = _hits;

    return Scaffold(
      appBar: AppBar(title: Text(t.search)),
      bottomNavigationBar: const BannerAdWidget(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _q,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchText(),
                    decoration: InputDecoration(
                      hintText: t.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _q.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _q.clear()),
                            ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _busy ? null : _searchText,
                  child: Text(t.searchGo),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _searchPhoto,
                icon: const Icon(Icons.image_search),
                label: Text(t.searchByPhoto),
              ),
            ),
          ),
          if (_busy) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: hits == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        t.searchEmptyHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ),
                  )
                : hits.isEmpty
                ? Center(
                    child: Text(
                      t.searchNoResults,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: hits.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                          child: Text(
                            t.searchResults(hits.length),
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: cs.primary),
                          ),
                        );
                      }
                      return _HitTile(hit: hits[i - 1], photoMode: _photoMode);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _HitTile extends StatelessWidget {
  final SearchHit hit;
  final bool photoMode;
  const _HitTile({required this.hit, required this.photoMode});

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final fileOf = AppScope.of(context).store.photos.fileOf;
    final date = parseDateKey(hit.date);
    final e = hit.entry;
    final (bg, fg) = e == null
        ? (cs.surfaceContainerHighest, cs.onSurface)
        : entryColors(e, cs);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => DayScreen(date: date))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat(t.dateFormatFull, locale).format(date),
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(color: cs.primary),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                ],
              ),
              // 내용 (키워드 앞뒤 5자)
              if (hit.snippet.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hit.snippet,
                    style: TextStyle(color: fg, fontSize: 14),
                  ),
                ),
              ],
              // 사진 (맞은 사진 앞뒤 1장)
              if (hit.photos.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final p in hit.photos)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: photoMode && p.id == hit.matchedPhoto?.id
                                ? Border.all(color: cs.primary, width: 3)
                                : null,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.file(
                            fileOf(p.thumb ?? p.file!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                ColoredBox(color: cs.surfaceContainerHighest),
                          ),
                        ),
                      ),
                    if (photoMode && hit.matchedPhoto != null)
                      Text(
                        t.searchSimilarPhoto,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
