import 'dart:io';

void main() {
  final file = File('lib/admin/widgets/admin_sidebar.dart');
  var content = file.readAsStringSync();

  // Fix import
  content = content.replaceAll(
      "import 'package:college_project/core/app_theme.dart' as app_theme;",
      "import '../core/app_theme.dart';"
  );
  content = content.replaceAll(
      "import '../../core/app_theme.dart';",
      "import '../core/app_theme.dart';"
  );

  // Fix app_theme.AppTheme references
  content = content.replaceAll("app_theme.AppTheme", "AppTheme");

  // Remove trailing constants
  final RegExp constWidgetRegex = RegExp(r'const\s+([A-Za-z0-9_]+\([^)]*AppTheme\.[^)]*\))');
  content = content.replaceAllMapped(constWidgetRegex, (m) => m.group(1)!);
  
  // Broader const removal for specific flutter widgets utilizing AppTheme
  content = content.replaceAll('const Icon(', 'Icon(');
  content = content.replaceAll('const Text(', 'Text(');
  content = content.replaceAll('const TextStyle(', 'TextStyle(');
  content = content.replaceAll('const BorderSide(', 'BorderSide(');
  content = content.replaceAll('const BoxDecoration(', 'BoxDecoration(');
  content = content.replaceAll('const EdgeInsets', 'EdgeInsets');
  
  file.writeAsStringSync(content);
}
