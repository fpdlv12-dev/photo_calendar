import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_scope.dart';
import '../l10n/app_localizations.dart';
import '../util/dates.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/month_grid.dart';
import 'day_screen.dart';
import 'settings_screen.dart';

/// 홈: 좌우 스와이프로 월 이동, 하단 배너.
class MonthScreen extends StatefulWidget {
  const MonthScreen({super.key});

  @override
  State<MonthScreen> createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  late final PageController _page;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _page = PageController(initialPage: monthIndex(_month));
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _goToday() {
    final now = DateTime.now();
    _page.animateToPage(
      monthIndex(now),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final scope = AppScope.of(context);
    final settings = scope.settings;
    final store = scope.store;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              tooltip: t.previousMonth,
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _page.previousPage(
                  duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
            ),
            Expanded(
              child: Text(
                DateFormat(t.monthFormat, locale).format(_month),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              tooltip: t.nextMonth,
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _page.nextPage(
                  duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: t.today,
            icon: const Icon(Icons.today_outlined),
            onPressed: _goToday,
          ),
          IconButton(
            tooltip: t.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: ListenableBuilder(
              listenable: Listenable.merge([settings, store]),
              builder: (context, _) => PageView.builder(
                controller: _page,
                onPageChanged: (i) => setState(() => _month = monthFromIndex(i)),
                itemBuilder: (context, i) {
                  final m = monthFromIndex(i);
                  return MonthGrid(
                    month: m,
                    data: store.monthData(m),
                    mode: settings.photoMode,
                    weekStart: settings.weekStart,
                    showText: settings.showText,
                    fileOf: store.photos.fileOf,
                    onTapDay: (d) => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DayScreen(date: d)),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
