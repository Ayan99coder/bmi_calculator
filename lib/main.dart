import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const BMIApp());
}

// ─── Color Palette ───────────────────────────────────────────────────────────
class AppColors {
  static const Color bg = Color(0xFF0A0E1A);
  static const Color card = Color(0xFF131929);
  static const Color cardActive = Color(0xFF1E2D4A);
  static const Color accent = Color(0xFF00D4FF);
  static const Color accentSecondary = Color(0xFF7B4FFF);
  static const Color accentGreen = Color(0xFF00E5A0);
  static const Color accentRed = Color(0xFFFF4E6A);
  static const Color accentOrange = Color(0xFFFFAA00);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A9BBC);
  static const Color divider = Color(0xFF1E2D4A);
}

class BMIApp extends StatelessWidget {
  const BMIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.card,
        ),
      ),
      home: const BMIHomePage(),
    );
  }
}

// ─── Home Page ────────────────────────────────────────────────────────────────
class BMIHomePage extends StatefulWidget {
  const BMIHomePage({super.key});

  @override
  State<BMIHomePage> createState() => _BMIHomePageState();
}

class _BMIHomePageState extends State<BMIHomePage>
    with TickerProviderStateMixin {
  bool _isMale = true;
  double _height = 170; // cm
  double _weight = 70; // kg
  int _age = 25;

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _calculate() {
    final double heightM = _height / 100;
    final double bmi = _weight / (heightM * heightM);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => BMIResultPage(
          bmi: bmi,
          weight: _weight,
          height: _height,
          age: _age,
          isMale: _isMale,
        ),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildGenderRow(),
                const SizedBox(height: 20),
                _buildHeightCard(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildCounterCard('Weight', _weight.toInt(), 'kg',
                        onInc: () => setState(() => _weight = (_weight + 1).clamp(30, 200)),
                        onDec: () => setState(() => _weight = (_weight - 1).clamp(30, 200)))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCounterCard('Age', _age, 'yrs',
                        onInc: () => setState(() => _age = (_age + 1).clamp(5, 120)),
                        onDec: () => setState(() => _age = (_age - 1).clamp(5, 120)))),
                  ],
                ),
                const SizedBox(height: 28),
                _buildCalculateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.accent, AppColors.accentSecondary],
          ).createShader(bounds),
          child: const Text(
            'BMI Calculator',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Know Your Body Mass Index',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildGenderRow() {
    return Row(
      children: [
        Expanded(child: _buildGenderCard(true)),
        const SizedBox(width: 16),
        Expanded(child: _buildGenderCard(false)),
      ],
    );
  }

  Widget _buildGenderCard(bool isMale) {
    final bool selected = _isMale == isMale;
    return GestureDetector(
      onTap: () => setState(() => _isMale = isMale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: selected ? AppColors.cardActive : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColors.accent.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
              ),
              child: Icon(
                isMale ? Icons.male_rounded : Icons.female_rounded,
                size: 42,
                color: selected ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isMale ? 'Male' : 'Female',
              style: TextStyle(
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightCard() {
    return _GlassCard(
      child: Column(
        children: [
          const Text(
            'HEIGHT',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${_height.toInt()}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const TextSpan(
                  text: ' cm',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accent.withOpacity(0.2),
            ),
            child: Slider(
              value: _height,
              min: 100,
              max: 220,
              onChanged: (v) => setState(() => _height = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('100 cm', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              Text('220 cm', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterCard(
    String label,
    int value,
    String unit, {
    required VoidCallback onInc,
    required VoidCallback onDec,
  }) {
    return _GlassCard(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$value',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundButton(icon: Icons.remove, onTap: onDec),
              const SizedBox(width: 16),
              _RoundButton(icon: Icons.add, onTap: onInc),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return ScaleTransition(
      scale: _pulseAnim,
      child: GestureDetector(
        onTap: _calculate,
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.accentSecondary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monitor_weight_outlined, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text(
                'CALCULATE BMI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Glass Card ───────────────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: child,
    );
  }
}

// ─── Round Button ─────────────────────────────────────────────────────────────
class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.cardActive,
          border: Border.all(color: AppColors.accent.withOpacity(0.4), width: 1.5),
        ),
        child: Icon(icon, color: AppColors.accent, size: 22),
      ),
    );
  }
}

// ─── Result Page ──────────────────────────────────────────────────────────────
class BMIResultPage extends StatefulWidget {
  final double bmi;
  final double weight;
  final double height;
  final int age;
  final bool isMale;

  const BMIResultPage({
    super.key,
    required this.bmi,
    required this.weight,
    required this.height,
    required this.age,
    required this.isMale,
  });

  @override
  State<BMIResultPage> createState() => _BMIResultPageState();
}

class _BMIResultPageState extends State<BMIResultPage>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late AnimationController _slideController;
  late Animation<double> _circleAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  String get _category {
    if (widget.bmi < 18.5) return 'Underweight';
    if (widget.bmi < 25.0) return 'Normal';
    if (widget.bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color get _categoryColor {
    if (widget.bmi < 18.5) return AppColors.accentOrange;
    if (widget.bmi < 25.0) return AppColors.accentGreen;
    if (widget.bmi < 30.0) return AppColors.accentOrange;
    return AppColors.accentRed;
  }

  String get _advice {
    if (widget.bmi < 18.5) {
      return 'You are underweight. Consider increasing caloric intake with nutritious foods and consult a doctor.';
    } else if (widget.bmi < 25.0) {
      return 'Great job! Your BMI is in the healthy range. Keep up with regular exercise and a balanced diet.';
    } else if (widget.bmi < 30.0) {
      return 'You are slightly overweight. A combination of exercise and a balanced diet can help reach your ideal weight.';
    } else {
      return 'Your BMI indicates obesity. It is advised to consult a healthcare provider for a personalized plan.';
    }
  }

  @override
  void initState() {
    super.initState();

    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _circleAnim = CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeOutBack,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _fadeAnim = CurvedAnimation(parent: _slideController, curve: Curves.easeIn);

    Future.delayed(const Duration(milliseconds: 200), () {
      _circleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _circleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBMICircle(),
                      const SizedBox(height: 28),
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: Column(
                            children: [
                              _buildCategoryChip(),
                              const SizedBox(height: 20),
                              _buildStatsRow(),
                              const SizedBox(height: 20),
                              _buildAdviceCard(),
                              const SizedBox(height: 20),
                              _buildScaleBar(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildRetryButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 18),
          ),
        ),
        const Expanded(
          child: Text(
            'Your Result',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
    );
  }

  Widget _buildBMICircle() {
    return ScaleTransition(
      scale: _circleAnim,
      child: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: _CirclePainter(color: _categoryColor),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.bmi.toStringAsFixed(1),
                    style: TextStyle(
                      color: _categoryColor,
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'BMI',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: _categoryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _categoryColor.withOpacity(0.5), width: 1.5),
      ),
      child: Text(
        _category,
        style: TextStyle(
          color: _categoryColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard('Height', '${widget.height.toInt()} cm', Icons.height_rounded),
        const SizedBox(width: 12),
        _buildStatCard('Weight', '${widget.weight.toInt()} kg', Icons.fitness_center_rounded),
        const SizedBox(width: 12),
        _buildStatCard('Age', '${widget.age} yrs', Icons.person_rounded),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _categoryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _categoryColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: _categoryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _advice,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleBar() {
    // clamp bmi to 10–40 range for visualization
    final double clampedBmi = widget.bmi.clamp(10.0, 40.0);
    final double fraction = (clampedBmi - 10) / 30;

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BMI SCALE',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              gradient: const LinearGradient(
                colors: [
                  AppColors.accentOrange,
                  AppColors.accentGreen,
                  AppColors.accentOrange,
                  AppColors.accentRed,
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(builder: (ctx, constraints) {
            return Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('10', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    Text('18.5', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    Text('25', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    Text('30', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    Text('40', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
                Positioned(
                  left: fraction * constraints.maxWidth - 6,
                  top: -28,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _categoryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _categoryColor.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accent, AppColors.accentSecondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'RECALCULATE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Circle Painter ───────────────────────────────────────────────────────────
class _CirclePainter extends CustomPainter {
  final Color color;
  _CirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Outer glow ring
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = color.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, radius - 6, glowPaint);

    // Solid ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = color.withOpacity(0.8)
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 6, ringPaint);

    // Inner fill
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.07);
    canvas.drawCircle(center, radius - 8, fillPaint);
  }

  @override
  bool shouldRepaint(_CirclePainter old) => old.color != color;
}
