// Run after compiling IANA sources to fat TZif; see third_party/tzdb/README.md.
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:timezone/src/tools.dart';
import 'package:timezone/src/tzdb.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/tzdata.dart' as tzfile;

void main(List<String> args) {
  if (args.length != 2) {
    throw ArgumentError(
      'Usage: dart run tool/generate_timezone_data.dart '
      '<zoneinfo directory> <IANA version>',
    );
  }
  final db = LocationDatabase();
  final files =
      Directory(args[0]).listSync(recursive: true).whereType<File>().toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final name = p.relative(file.path, from: args[0]).replaceAll('\\', '/');
    db.add(
      tzfileLocationToNativeLocation(
        tzfile.Location.fromBytes(name, file.readAsBytesSync()),
      ),
    );
  }
  if (db.locations.length < 500) {
    throw StateError('Incomplete timezone database: ${db.locations.length}');
  }
  final encoded = base64Encode(tzdbSerialize(filterTimeZoneData(db).db));
  final output = StringBuffer(
    '''// GENERATED FILE. Do not edit. IANA tzdb ${args[1]} (public domain).
// Regenerate with tool/generate_timezone_data.dart; includes backward aliases.
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;

const ianaVersion = '${args[1]}';

void initializeTimeZones() => tz.initializeDatabase(base64Decode(_data));

const _data =
''',
  );
  for (var i = 0; i < encoded.length; i += 76) {
    final end = i + 76 < encoded.length ? i + 76 : encoded.length;
    output.writeln("    '${encoded.substring(i, end)}'");
  }
  output.writeln(';');
  final target = File('lib/time/iana_data.dart');
  target.parent.createSync(recursive: true);
  target.writeAsStringSync(output.toString());
  stdout.writeln('Generated ${args[1]}: ${db.locations.length} locations.');
}
