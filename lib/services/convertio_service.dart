import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ConvertioService {
  static const String _apiKey = '3299fb40e7bdfab8021f132f67b35aac';
  static const String _baseUrl = 'https://api.convertio.co';

  static Future<File?> scaricaConvertiERiformatta(int giornata) async {
    try {
      final url = 'https://www.pianetafanta.it/voti-ufficiosi-excel.asp?giornataScelta=$giornata&searchBonus=';
      final response = await http.get(Uri.parse(url));
      final tempDir = await getTemporaryDirectory();
      final xlsFile = File('${tempDir.path}/giornata$giornata.xls');
      await xlsFile.writeAsBytes(response.bodyBytes);

      final initResponse = await http.post(
        Uri.parse('$_baseUrl/convert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'apikey': _apiKey,
          'input': 'upload',
          'file': xlsFile.uri.pathSegments.last,
          'outputformat': 'xlsx',
        }),
      );

      final initData = jsonDecode(initResponse.body);

      if (initData['error'] != null) {
        print(initData['error']);
        return null;
      }

      final jobId = initData['data']['id'];
      final uploadUrl = '$_baseUrl/convert/$jobId/${xlsFile.uri.pathSegments.last}';
      await http.put(Uri.parse(uploadUrl), body: await xlsFile.readAsBytes());

      while (true) {
        await Future.delayed(const Duration(seconds: 2));
        final status = await http.get(Uri.parse('$_baseUrl/convert/$jobId/status'));
        final statusData = jsonDecode(status.body);
        final step = statusData['data']['step'];

        if (step == 'finish') {
          final downloadUrl = statusData['data']['output']['url'];
          final downloadResponse = await http.get(Uri.parse(downloadUrl));
          final xlsxFile = File('${tempDir.path}/giornata$giornata.xlsx');
          await xlsxFile.writeAsBytes(downloadResponse.bodyBytes);
          return await riformattaEGeneraExcel(xlsxFile);
        }

        if (step == 'error') {
          print("❌ Conversione fallita: ${statusData['data']}");
          return null;
        }
      }
    } catch (e) {
      print('❌ Errore ConvertioService.giornata $giornata: $e');
      return null;
    }
  }

  static Future<File?> riformattaEGeneraExcel(File inputFile) async {
    try {
      final bytes = await inputFile.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final newExcel = Excel.createExcel();

      final defaultSheet = newExcel.getDefaultSheet();
      if (defaultSheet != null && defaultSheet != 'Riformattato') {
        newExcel.rename(defaultSheet, 'Riformattato');
      }

      final sheet = newExcel['Riformattato'];

      for (var table in excel.tables.keys) {
        final rows = excel.tables[table]!.rows;
        int i = 0;

        while (i < rows.length) {
          final row = rows[i];

          final isAllCaps = row.every((cell) {
            final val = cell?.value?.toString();
            if (val == null || val.trim().isEmpty) return false;
            final isUpperCase = val == val.toUpperCase();
            final isLettersOnly = RegExp(r"^[A-ZÀ-Ü\s.\'\-]+$").hasMatch(val);
            return isUpperCase && isLettersOnly;
          });

          if (isAllCaps && i + 2 < rows.length) {

            final secondaRiga = rows[i + 1]
                .map((c) => c?.value?.toString().trim() ?? '')
                .join(' ')
                .split(RegExp(r'\s+'));

            final terzaRiga = rows[i + 2]
                .map((c) => c?.value?.toString().trim() ?? '')
                .join(' ')
                .split(RegExp(r'\s+'));

            final nome = row.map((c) => c?.value?.toString() ?? '').join(' ').trim();
            final nomeConTerzaRiga = '$nome ${terzaRiga.join(' ')}';

            final codice = secondaRiga.isNotEmpty ? secondaRiga[0] : '??';
            final ruoli = secondaRiga.sublist(1, 3);
            final team = secondaRiga.length > 3 ? secondaRiga[3] : '??';
            final valori = secondaRiga.sublist(4);

            final finalList = [codice, ...nomeConTerzaRiga.split(' '), ...ruoli, team, ...valori];
            final colonSeparated = finalList.map((e) => e.trim()).join(' ');
            sheet.appendRow([TextCellValue(colonSeparated)]);
            i += 3;
          } else {
            final valori = row.map((c) {
              final text = c?.value?.toString() ?? '';
              return text.trim().replaceAll(RegExp(r'\s+'), ' ');
            }).toList();

            if (valori.any((v) => v.isNotEmpty)) {
              final colonSeparated = valori.join(':');
              sheet.appendRow([TextCellValue(colonSeparated)]);
            }
            i++;
          }
        }
      }

      final dir = await getTemporaryDirectory();
      final outputFile = File('${dir.path}/Riformattato.xlsx');
      await outputFile.writeAsBytes(newExcel.encode()!);
      return outputFile;
    } catch (e) {
      print('❌ Errore durante la riformattazione: $e');
      return null;
    }
  }
  static leggiExcelRigaPerRiga(File file) {
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    for (var sheetName in excel.tables.keys) {
      final sheet = excel.tables[sheetName];

      print('--- Foglio: $sheetName ---');

      for (var row in sheet!.rows) {
        final riga = row.map((cell) => cell?.value.toString() ?? '').join(' | ');
        print(riga);
      }
    }
  }
}
