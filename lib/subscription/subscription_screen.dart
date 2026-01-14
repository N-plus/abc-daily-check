import 'dart:math' as math;

import 'package:flutter/material.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _selectedTheme = 'default';
  String _selectedFont = 'default';

  final List<ThemeColor> _themes = [
    ThemeColor(
      'default',
      'デフォルト',
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF95E1D3),
    ),
    ThemeColor(
      'sunset',
      '夕焼け',
      const Color(0xFFFF8B94),
      const Color(0xFFFFB366),
      const Color(0xFFFFE66D),
    ),
    ThemeColor(
      'forest',
      '森林',
      const Color(0xFF6BCF7F),
      const Color(0xFF4A9B8E),
      const Color(0xFFA8E6CF),
    ),
    ThemeColor(
      'ocean',
      '海',
      const Color(0xFF4A90E2),
      const Color(0xFF7FB3D5),
      const Color(0xFFB4E7F5),
    ),
    ThemeColor(
      'lavender',
      'ラベンダー',
      const Color(0xFFB39DDB),
      const Color(0xFF9FA8DA),
      const Color(0xFFD1C4E9),
    ),
  ];

  final List<SubscriptionFontStyle> _fonts = [
    SubscriptionFontStyle('default', 'デフォルト', FontWeight.w300),
    SubscriptionFontStyle('round', '丸ゴシック', FontWeight.w400),
    SubscriptionFontStyle('serif', '明朝体', FontWeight.w300),
    SubscriptionFontStyle('bold', '太字', FontWeight.w700),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ThemeColor get _currentTheme =>
      _themes.firstWhere((theme) => theme.id == _selectedTheme);
  SubscriptionFontStyle get _currentFont =>
      _fonts.firstWhere((font) => font.id == _selectedFont);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        leadingWidth: 96,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: Color(0xFF1F2937),
          ),
          label: const Text(
            '戻る',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'プレミアム機能',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'より深く、自分を観測する',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF1F2937),
                      unselectedLabelColor: const Color(0xFF9CA3AF),
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                      indicatorColor: const Color(0xFF1F2937),
                      indicatorWeight: 2,
                      tabs: const [
                        Tab(text: '機能一覧'),
                        Tab(text: 'カスタマイズ'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeaturesTab(),
                  _buildCustomizeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildFeatureCard(
            icon: Icons.trending_up,
            title: '月と年の波グラフ',
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: CustomPaint(
                    painter: WaveGraphPainter(),
                    size: const Size(double.infinity, 180),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '月や年単位での自分の波を、なめらかな曲線で観測できます。\n良い・悪いではなく、リズムとして見る。',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildFeatureCard(
            icon: Icons.calendar_today,
            title: '月の詳細ビュー',
            child: Column(
              children: [
                _buildMonthItem('1/1', 'B', 'ゆっくり過ごした'),
                const SizedBox(height: 12),
                _buildMonthItem('1/2', 'A', '友達と会った'),
                const SizedBox(height: 12),
                _buildMonthItem('1/3', 'C', '疲れた、早く寝た'),
                const SizedBox(height: 16),
                const Text(
                  '日付とABC、メモを一覧で振り返れます。\n探すのではなく、眺めるための画面。',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSimpleFeature(Icons.check, '広告なし', '集中を妨げない、静かな空間'),
          const SizedBox(height: 16),
          _buildSimpleFeature(Icons.palette, 'テーマカラー', 'あなたの好みの色で記録する'),
          const SizedBox(height: 16),
          _buildSimpleFeature(
            Icons.text_fields,
            '文字デザイン',
            'ABCの見た目を変更できます',
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1F2937), Color(0xFF374151)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Text(
                  '¥300',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '月額 / 自動更新',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1F2937),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'プレミアムを始める',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'いつでもキャンセルできます',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'テーマカラー',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _themes.length,
                  itemBuilder: (context, index) {
                    final theme = _themes[index];
                    final isSelected = _selectedTheme == theme.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTheme = theme.id),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1F2937)
                                : const Color(0xFFE5E7EB),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildColorCircle(theme.colorA),
                                const SizedBox(width: 8),
                                _buildColorCircle(theme.colorB),
                                const SizedBox(width: 8),
                                _buildColorCircle(theme.colorC),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              theme.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '文字デザイン',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 24),
                ..._fonts.map((font) {
                  final isSelected = _selectedFont == font.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFont = font.id),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF9FAFB)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1F2937)
                                : const Color(0xFFE5E7EB),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ABC',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: font.weight,
                              ),
                            ),
                            Text(
                              font.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'プレビュー',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPreviewCircle('A', _currentTheme.colorA),
                    const SizedBox(width: 16),
                    _buildPreviewCircle('B', _currentTheme.colorB),
                    const SizedBox(width: 16),
                    _buildPreviewCircle('C', _currentTheme.colorC),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6B7280), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildMonthItem(String date, String abc, String memo) {
    Color getColor(String rating) {
      if (rating == 'A') return const Color(0xFFFF6B6B);
      if (rating == 'B') return const Color(0xFF4ECDC4);
      return const Color(0xFF95E1D3);
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: getColor(abc),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              abc,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              memo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleFeature(
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6B7280), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildPreviewCircle(String letter, Color color) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 24,
          fontWeight: _currentFont.weight,
          color: Colors.white,
        ),
      ),
    );
  }
}

class WaveGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const points = 30;

    final pathA = Path();
    for (var i = 0; i < points; i++) {
      final x = (i / (points - 1)) * size.width;
      final y = size.height - (math.sin(i / 5) * 0.3 + 0.5) * size.height;
      if (i == 0) {
        pathA.moveTo(x, y);
      } else {
        pathA.lineTo(x, y);
      }
    }
    canvas.drawPath(
      pathA,
      Paint()
        ..color = const Color(0xFFFF6B6B).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final pathB = Path();
    for (var i = 0; i < points; i++) {
      final x = (i / (points - 1)) * size.width;
      final y = size.height - (math.cos(i / 4) * 0.2 + 0.4) * size.height;
      if (i == 0) {
        pathB.moveTo(x, y);
      } else {
        pathB.lineTo(x, y);
      }
    }
    canvas.drawPath(
      pathB,
      Paint()
        ..color = const Color(0xFF4ECDC4).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final pathC = Path();
    for (var i = 0; i < points; i++) {
      final x = (i / (points - 1)) * size.width;
      final y = size.height - (math.sin(i / 6) * 0.15 + 0.25) * size.height;
      if (i == 0) {
        pathC.moveTo(x, y);
      } else {
        pathC.lineTo(x, y);
      }
    }
    canvas.drawPath(
      pathC,
      Paint()
        ..color = const Color(0xFF95E1D3).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ThemeColor {
  ThemeColor(this.id, this.name, this.colorA, this.colorB, this.colorC);

  final String id;
  final String name;
  final Color colorA;
  final Color colorB;
  final Color colorC;
}

class SubscriptionFontStyle {
  SubscriptionFontStyle(this.id, this.name, this.weight);

  final String id;
  final String name;
  final FontWeight weight;
}
