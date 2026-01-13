import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'subscription/subscription_screen.dart';

void main() {
  runApp(const AbcDailyCheckApp());
}

class AbcDailyCheckApp extends StatelessWidget {
  const AbcDailyCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '今日のABC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FB),
      ),
      home: const BottomNavigationScaffold(),
    );
  }
}

class BottomNavigationScaffold extends StatefulWidget {
  const BottomNavigationScaffold({super.key});

  @override
  State<BottomNavigationScaffold> createState() =>
      _BottomNavigationScaffoldState();
}

class _BottomNavigationScaffoldState extends State<BottomNavigationScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          WeeklyHomePage(),
          WaveScreen(),
          MonthScreen(),
          SubscriptionScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF1F2937),
        unselectedItemColor: const Color(0xFF9CA3AF),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_week),
            label: '今週',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: '波',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '月',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}

class WaveScreen extends StatelessWidget {
  const WaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Coming soon'),
    );
  }
}

class MonthScreen extends StatelessWidget {
  const MonthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Coming soon'),
    );
  }
}

class WeeklyHomePage extends StatefulWidget {
  const WeeklyHomePage({super.key});

  @override
  State<WeeklyHomePage> createState() => _WeeklyHomePageState();
}

class _WeeklyHomePageState extends State<WeeklyHomePage> {
  static const _prefsEntriesKey = 'entries';
  static const _prefsLastOpenKey = 'lastOpenDate';
  static const _prefsLastPraiseWeekKey = 'lastPraiseWeekStart';

  final Map<String, DayEntry> _entries = {};
  String? _weeklyPraiseMessage;
  late SharedPreferences _prefs;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    _prefs = await SharedPreferences.getInstance();
    final stored = _prefs.getString(_prefsEntriesKey);
    if (stored != null) {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        _entries[entry.key] = DayEntry.fromJson(entry.value);
      }
    }
    await _updateWeeklyPraise();
    setState(() {
      _loading = false;
    });
  }

  Future<void> _persistEntries() async {
    final encoded = <String, dynamic>{
      for (final entry in _entries.entries) entry.key: entry.value.toJson(),
    };
    await _prefs.setString(_prefsEntriesKey, jsonEncode(encoded));
  }

  Future<void> _updateWeeklyPraise() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final lastOpenRaw = _prefs.getString(_prefsLastOpenKey);
    final lastPraiseWeek = _prefs.getString(_prefsLastPraiseWeekKey);
    final lastOpen = lastOpenRaw != null ? DateTime.parse(lastOpenRaw) : null;
    final mostRecentSunday = today.subtract(Duration(days: today.weekday % 7));
    final weekStart = _startOfWeek(today);

    final shouldCheck =
        today.weekday == DateTime.sunday ||
        lastOpen == null ||
        lastOpen.isBefore(mostRecentSunday);

    if (shouldCheck && lastPraiseWeek != _formatDate(weekStart)) {
      final praise = _calculateWeeklyPraise(today);
      _weeklyPraiseMessage = praise;
      await _prefs.setString(_prefsLastPraiseWeekKey, _formatDate(weekStart));
    }

    await _prefs.setString(_prefsLastOpenKey, _formatDate(today));
  }

  String? _calculateWeeklyPraise(DateTime today) {
    const praiseCandidates = [
      '今週は、いい流れでした。',
      'この一週間、調子がよかったみたいです。',
      '気づいたら、いい週でしたね。',
      'いい調子が続いていました。',
    ];
    var aCount = 0;
    var totalScore = 0;
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final key = _formatDate(date);
      final entry = _entries[key];
      if (entry == null) {
        continue;
      }
      if (entry.rating == Rating.a) {
        aCount += 1;
      }
      totalScore += entry.score;
    }

    final averageScore = totalScore / 7.0;
    if (aCount >= 4 || averageScore >= 3.8) {
      final random = Random();
      return praiseCandidates[random.nextInt(praiseCandidates.length)];
    }
    return null;
  }

  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }

  List<DateTime> _currentWeekDates() {
    final start = _startOfWeek(DateUtils.dateOnly(DateTime.now()));
    return List.generate(7, (index) => start.add(Duration(days: index)));
  }

  Future<void> _openTodayModal() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final key = _formatDate(today);
    final existing = _entries[key];
    final controller = TextEditingController(text: existing?.memo ?? '');
    Rating? selected = existing?.rating;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> saveEntry({bool showToastForA = false}) async {
              if (selected == null) {
                return;
              }
              final entry = DayEntry(
                date: key,
                rating: selected!,
                memo: controller.text.trim().isEmpty
                    ? null
                    : controller.text.trim(),
              );
              _entries[key] = entry;
              await _persistEntries();
              if (showToastForA && selected == Rating.a && mounted) {
                final messages = [
                  'いい感じの一日ですね',
                  '今日は調子よさそうです',
                  '今日のリズム、良さそうです',
                ];
                final random = Random();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(messages[random.nextInt(messages.length)]),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              setState(() {});
            }

            void onSelectRating(Rating rating) {
              setModalState(() {
                selected = rating;
              });
              saveEntry(showToastForA: rating == Rating.a);
            }

            void onMemoChanged(String value) {
              if (selected != null) {
                saveEntry();
              }
            }

            final pastMemos = _entries.values
                .map((entry) => entry.memo)
                .whereType<String>()
                .map((memo) => memo.trim())
                .where((memo) => memo.isNotEmpty)
                .toSet()
                .toList()
              ..sort();

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '今日はどうだった？',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: Rating.values.map((rating) {
                        final isSelected = selected == rating;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: OutlinedButton(
                              onPressed: () => onSelectRating(rating),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                backgroundColor: isSelected
                                    ? rating.color.withOpacity(0.15)
                                    : Colors.white,
                                side: BorderSide(color: rating.color, width: 2),
                              ),
                              child: Text(
                                rating.label,
                                style: TextStyle(
                                  color: rating.color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '今日のメモ（任意）',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      minLines: 3,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: '気づいたことを少しだけ。',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F4F7),
                      ),
                      onChanged: onMemoChanged,
                    ),
                    if (pastMemos.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        '過去のメモから',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: pastMemos.map((memo) {
                          return ActionChip(
                            label: Text(memo),
                            onPressed: () {
                              controller.text = memo;
                              controller.selection = TextSelection.fromPosition(
                                TextPosition(offset: memo.length),
                              );
                              setModalState(() {});
                              onMemoChanged(memo);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double? _currentMonthAverage() {
    final now = DateTime.now();
    final scores = _entries.values.where((entry) {
      final date = DateTime.parse(entry.date);
      return date.year == now.year && date.month == now.month;
    }).map((entry) => entry.score);

    if (scores.isEmpty) {
      return null;
    }

    final total = scores.fold(0, (sum, value) => sum + value);
    return total / scores.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final weekDates = _currentWeekDates();
    final todayKey = _formatDate(DateUtils.dateOnly(DateTime.now()));
    final monthAverage = _currentMonthAverage();

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日のABC'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SubscriptionScreen(),
                ),
              );
            },
            child: const Text('プレミアム'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_weeklyPraiseMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _weeklyPraiseMessage!,
                    style: const TextStyle(
                      color: Color(0xFF7A3C2A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                '今週ビュー',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _WeeklyTable(
                weekDates: weekDates,
                entries: _entries,
                todayKey: todayKey,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openTodayModal,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('今日のABCを記録する'),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '月平均（数値のみ）',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      monthAverage == null
                          ? '-'
                          : monthAverage.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'サブスク機能',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8),
                    Text('・月・年の波グラフ'),
                    Text('・月の詳細ビュー'),
                    Text('・広告削除'),
                    Text('・テーマカラー / 背景 / A/B/C文字デザイン'),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E3E7)),
                ),
                child: const Center(
                  child: Text('広告バナー'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyTable extends StatelessWidget {
  const _WeeklyTable({
    required this.weekDates,
    required this.entries,
    required this.todayKey,
  });

  final List<DateTime> weekDates;
  final Map<String, DayEntry> entries;
  final String todayKey;

  @override
  Widget build(BuildContext context) {
    const weekdayLabels = ['月', '火', '水', '木', '金', '土', '日'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(7, (index) {
              return Expanded(
                child: Center(
                  child: Text(
                    weekdayLabels[index],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: weekDates.map((date) {
              final key = _formatDate(date);
              final entry = entries[key];
              final isToday = key == todayKey;
              final label = entry?.rating.label ?? '－';
              final color = entry?.rating.color ?? Colors.black26;

              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isToday ? const Color(0xFFF1F5FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class DayEntry {
  DayEntry({
    required this.date,
    required this.rating,
    required this.memo,
  }) : score = rating.score;

  final String date;
  final Rating rating;
  final String? memo;
  final int score;

  factory DayEntry.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    final rating = Rating.values.firstWhere(
      (value) => value.label == map['rating'],
      orElse: () => Rating.b,
    );
    return DayEntry(
      date: map['date'] as String,
      rating: rating,
      memo: map['memo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'rating': rating.label,
      'memo': memo,
      'score': score,
    };
  }
}

enum Rating {
  a('A', 5, Colors.red),
  b('B', 3, Colors.blue),
  c('C', 1, Colors.green);

  const Rating(this.label, this.score, this.color);

  final String label;
  final int score;
  final Color color;
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
