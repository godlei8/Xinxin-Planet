import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/database/database_helper.dart';

class BackupService {
  static Future<Directory> get _backupDirectory async {
    final baseDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(baseDir.path, 'backups'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<File> exportBackup() async {
    final dir = await _backupDirectory;
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final file = File(p.join(dir.path, 'xinxin_planet_backup_$timestamp.json'));
    final data = await DatabaseHelper.exportData();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file;
  }

  static Future<File?> latestBackupFile() async {
    final dir = await _backupDirectory;
    if (!await dir.exists()) {
      return null;
    }

    final files = await dir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .cast<File>()
        .toList();

    if (files.isEmpty) {
      return null;
    }

    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files.first;
  }

  static Future<File> restoreLatestBackup() async {
    final file = await latestBackupFile();
    if (file == null) {
      throw Exception('还没有可恢复的备份文件。');
    }

    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw Exception('备份文件格式无效。');
    }

    await DatabaseHelper.importData(decoded);
    return file;
  }

  static Future<File> shareLatestBackup() async {
    final file = await latestBackupFile();
    if (file == null) {
      throw Exception('还没有可分享的备份文件。');
    }

    await Share.shareXFiles(
      [XFile(file.path)],
      text: '馨馨星球数据备份',
      subject: '馨馨星球备份',
    );
    return file;
  }
}
