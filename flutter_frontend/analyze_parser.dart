import 'dart:io';

void main() {
  final res = Process.runSync('dart', ['analyze', '--format=machine']);
  final out = res.stdout.toString() + res.stderr.toString();
  for (final line in out.split('\n')) {
    if (line.contains('ERROR|') || line.contains('error|')) {
      print(line);
    }
  }
}
