import 'dart:io';

void main() {
  final RegExp exp = RegExp(r'AppTheme\.(\w+)');
  final Set<String> colors = {};
  
  final dir = Directory('lib');
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      final matches = exp.allMatches(content);
      for (final m in matches) {
        colors.add(m.group(1)!);
      }
    }
  }
  print(colors.join('\n'));
}
