import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../models/dashboard_stats_model.dart';

// ──────────────────────────────────────────
// STAT CARD (top row: Students, Teachers, etc.)
// ──────────────────────────────────────────
class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: AppTheme.accentGreen, size: 14),
              const SizedBox(width: 4),
              Text(change, style: TextStyle(color: AppTheme.accentGreen, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Text('this month', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// ATTENDANCE LINE CHART (custom painted)
// ──────────────────────────────────────────
class AttendanceLineChart extends StatelessWidget {
  final List<WeeklyAttendance> data;
  const AttendanceLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Attendance Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('This Week', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineChartPainter(data),
            ),
          ),
          const SizedBox(height: 8),
          // X-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: data.map((d) => Text(d.day, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted))).toList(),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<WeeklyAttendance> data;
  _LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final w = size.width;
    final h = size.height;

    // Grid lines
    final gridPaint = Paint()..color = const Color(0xFFE5E7EB)..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = h - (h * i / 4);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Y-axis labels
    final labelStyle = TextStyle(color: const Color(0xFF9CA3AF), fontSize: 10);
    for (int i = 0; i <= 4; i++) {
      final tp = TextPainter(text: TextSpan(text: '${i * 25}%', style: labelStyle), textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(-2, h - (h * i / 4) - tp.height / 2));
    }

    // Line + fill
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = w * i / (data.length - 1);
      final y = h - (h * data[i].percentage / 100);
      points.add(Offset(x, y));
    }

    // Fill gradient
    final fillPath = Path()..moveTo(points.first.dx, h);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF4F46E5).withValues(alpha: 0.15), const Color(0xFF4F46E5).withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots
    final dotPaint = Paint()..color = const Color(0xFF4F46E5);
    final dotBorder = Paint()..color = Colors.white..strokeWidth = 2..style = PaintingStyle.stroke;
    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 4, dotBorder);
    }

    // Tooltip on highest point
    int maxIdx = 0;
    for (int i = 1; i < data.length; i++) {
      if (data[i].percentage > data[maxIdx].percentage) maxIdx = i;
    }
    final tp = TextPainter(
      text: TextSpan(
        text: '${data[maxIdx].day}\n${data[maxIdx].percentage.toInt()}%',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600, height: 1.3),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    final tooltipW = tp.width + 16;
    final tooltipH = tp.height + 10;
    final tooltipX = points[maxIdx].dx - tooltipW / 2;
    final tooltipY = points[maxIdx].dy - tooltipH - 10;
    final tooltipRect = RRect.fromRectAndRadius(Rect.fromLTWH(tooltipX, tooltipY, tooltipW, tooltipH), const Radius.circular(6));
    canvas.drawRRect(tooltipRect, Paint()..color = const Color(0xFF1E1B4B));
    tp.paint(canvas, Offset(tooltipX + 8, tooltipY + 5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ──────────────────────────────────────────
// ATTENDANCE SUMMARY PILLS
// ──────────────────────────────────────────
class AttendanceSummaryRow extends StatelessWidget {
  final double avgRate;
  final int presentCount;
  final int absentCount;
  const AttendanceSummaryRow({super.key, required this.avgRate, required this.presentCount, required this.absentCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill(Icons.bar_chart_rounded, '${avgRate.toStringAsFixed(0)}%', 'Average Attendance\nThis Week', const Color(0xFF4F46E5)),
        const SizedBox(width: 12),
        _pill(Icons.check_circle_outline, '$presentCount', 'Present\nStudents', AppTheme.accentGreen),
        const SizedBox(width: 12),
        _pill(Icons.highlight_off, '$absentCount', 'Absent\nStudents', AppTheme.accentRed),
      ],
    );
  }

  Widget _pill(IconData icon, String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.replaceAll('\n', ' '), style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                      if (label.contains('Attendance')) ...[
                        const SizedBox(width: 2),
                        const Text('Students', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// DONUT CHART (Students Overview)
// ──────────────────────────────────────────
class StudentDonutChart extends StatelessWidget {
  final int active;
  final int pending;
  final int inactive;
  const StudentDonutChart({super.key, required this.active, required this.pending, required this.inactive});

  @override
  Widget build(BuildContext context) {
    final total = active + pending + inactive;
    if (total == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Students Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 130, height: 130,
                child: CustomPaint(
                  painter: _DonutPainter(active: active, pending: pending, inactive: inactive),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$total', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                        const Text('Total', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendRow('Active Students', active, total, const Color(0xFF4F46E5)),
                    const SizedBox(height: 12),
                    _legendRow('Pending Requests', pending, total, const Color(0xFFF59E0B)),
                    const SizedBox(height: 12),
                    _legendRow('Inactive Students', inactive, total, const Color(0xFF9CA3AF)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendRow(String label, int count, int total, Color color) {
    final pct = total > 0 ? (count * 100 / total).round() : 0;
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500))),
        Text('$count ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        Text('($pct%)', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int active, pending, inactive;
  _DonutPainter({required this.active, required this.pending, required this.inactive});

  @override
  void paint(Canvas canvas, Size size) {
    final total = active + pending + inactive;
    if (total == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const strokeWidth = 18.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    const startAngle = -pi / 2;

    final slices = [
      (active / total * 2 * pi, const Color(0xFF4F46E5)),
      (pending / total * 2 * pi, const Color(0xFFF59E0B)),
      (inactive / total * 2 * pi, const Color(0xFF9CA3AF)),
    ];

    double angle = startAngle;
    for (final (sweep, color) in slices) {
      final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, angle, sweep - 0.04, false, paint);
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
