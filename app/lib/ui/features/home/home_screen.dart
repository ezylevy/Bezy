import 'package:flutter/material.dart';
import '../../../core/audio/sound_service.dart';
import '../../../core/storage/progress_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../custom/custom_game_screen.dart';
import '../levels/world_map_screen.dart';

/// The welcoming home screen with Campaign, Custom Game, Instructions and Settings.
class HomeScreen extends StatefulWidget {
  final ProgressStorage storage;
  final SoundService sound;

  const HomeScreen({
    super.key,
    required this.storage,
    required this.sound,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final totalStars = widget.storage.getTotalStars();
    final isHaptics = widget.storage.isHapticsEnabled;
    final isSound = widget.storage.isSoundEnabled;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F172A),
                AppTheme.bgDark,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Top Settings Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Total Stars Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppTheme.gold, size: 22),
                            const SizedBox(width: 6),
                            Text(
                              '$totalStars כוכבים',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.gold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Settings Toggles
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isHaptics
                                  ? Icons.vibration_rounded
                                  : Icons.smartphone_rounded,
                              color: isHaptics
                                  ? AppTheme.pathCyan
                                  : AppTheme.textMuted,
                            ),
                            tooltip: 'רטט הפטי',
                            onPressed: () async {
                              await widget.storage.setHapticsEnabled(!isHaptics);
                              widget.sound.tileTap();
                              _refresh();
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              isSound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                              color: isSound ? AppTheme.pathCyan : AppTheme.textMuted,
                            ),
                            tooltip: 'צלילים',
                            onPressed: () async {
                              await widget.storage.setSoundEnabled(!isSound);
                              widget.sound.tileTap();
                              _refresh();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),

                  // Hero Icon & Title
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.startGreen, AppTheme.pathCyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.pathCyan.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.route_rounded,
                        size: 52,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'מסלול החיבור',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'משחק חשיבה ומתמטיקה מודולרי',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'נוצר על ידי עזי לוי',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.pathCyan,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Main Menu Buttons
                  _MenuCard(
                    title: 'מסע השלבים (קמפיין)',
                    subtitle: '4 עולמות עם חומות, מקפצות ושערים חכמים',
                    icon: Icons.map_rounded,
                    accentColor: AppTheme.startGreen,
                    onTap: () async {
                      widget.sound.tileTap();
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WorldMapScreen(
                            storage: widget.storage,
                            sound: widget.sound,
                          ),
                        ),
                      );
                      _refresh();
                    },
                  ),

                  const SizedBox(height: 14),

                  _MenuCard(
                    title: 'משחק חופשי (אינסופי)',
                    subtitle: 'לוחות 3x3 עד 9x9 עם שילוב אלמנטים מותאם',
                    icon: Icons.casino_rounded,
                    accentColor: AppTheme.pathCyan,
                    onTap: () {
                      widget.sound.tileTap();
                      showDialog(
                        context: context,
                        builder: (ctx) => CustomGameDialog(
                          storage: widget.storage,
                          sound: widget.sound,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  _MenuCard(
                    title: 'איך משחקים?',
                    subtitle: 'חוקי המשחק, משבצות מיוחדות וטיפים לניצחון',
                    icon: Icons.lightbulb_outline_rounded,
                    accentColor: AppTheme.gold,
                    onTap: () {
                      widget.sound.tileTap();
                      _showHowToPlay();
                    },
                  ),

                  const Spacer(flex: 2),

                  // Version info
                  const Text(
                    'גרסה 1.0.0 • מותאם לאנדרואיד',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHowToPlay() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.cardBorder),
          ),
          title: const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: AppTheme.gold),
              SizedBox(width: 8),
              Text('הוראות המשחק'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _ruleItem(
                  Icons.play_circle_fill_rounded,
                  AppTheme.startGreen,
                  'משבצת התחלה',
                  'התחילו מאחת ממשבצות ההתחלה בירוק הממוקמות בהיקף הלוח.',
                ),
                _ruleItem(
                  Icons.directions_walk_rounded,
                  AppTheme.pathCyan,
                  'תנועה בלוח',
                  'התקדמו למשבצת סמוכה (למעלה, למטה, ימינה או שמאלה). כל משבצת מוסיפה את ערכה לסכום.',
                ),
                _ruleItem(
                  Icons.flag_rounded,
                  AppTheme.targetPink,
                  'הגעה ליעד',
                  'משבצת היעד נמצאת במרכז. עליכם להגיע אליה בדיוק עם הסכום הנדרש!',
                ),
                _ruleItem(
                  Icons.fence_rounded,
                  AppTheme.wallGray,
                  'חומות אבן',
                  'מכשולים שחוסמים את המעבר – יש למצוא נתיב עוקף.',
                ),
                _ruleItem(
                  Icons.bolt_rounded,
                  AppTheme.trampolineOrange,
                  'מקפצות זינוק',
                  'מעניקות תוספת בונוס לסכום המצטבר.',
                ),
                _ruleItem(
                  Icons.lock_open_rounded,
                  AppTheme.smartGatePurple,
                  'שערים חכמים',
                  'נפתחים רק בעמידה בתנאי מספרי (למשל: סכום זוגי).',
                ),
                _ruleItem(
                  Icons.auto_awesome_rounded,
                  AppTheme.gold,
                  'רמז ופתרון חכם',
                  'נתקעתם? השתמשו ברמז החכם או במדריך הפתרון המפורט.',
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('הבנתי, סגור'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ruleItem(
      IconData icon, Color color, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
