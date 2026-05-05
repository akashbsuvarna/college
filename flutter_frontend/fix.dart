import 'dart:io';

void main() {
  final dir = Directory('lib');
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = entity.readAsStringSync();
      var original = content;

      // Fix missing opacity argument
      content = content.replaceAll('.withOpacity()', '.withOpacity(0.2)');
      
      // Fix imports
      content = content.replaceAll(
          "import 'package:college_project/core/app_theme.dart';",
          "import '../../core/app_theme.dart';"
      );

      // Remove const before AppTheme usages with withOpacity
      final RegExp constRegex = RegExp(r'const\s+([A-Za-z0-9_]+\([^)]*AppTheme\.[^)]*\.withOpacity\()');
      content = content.replaceAllMapped(constRegex, (m) => m.group(1)!);

      // Remove const for Icon(..., color: AppTheme.something) if that causes issues? 
      // Actually MaterialColor is const, so it should be fine. But just in case, let's remove const if it contains withOpacity:
      content = content.replaceAll('const Icon(color: AppTheme', 'Icon(color: AppTheme');

      if (content != original) {
        entity.writeAsStringSync(content);
      }
    }
  }
}
