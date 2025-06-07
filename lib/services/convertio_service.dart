import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ConvertioService {
  static const String _apiKey = '3299fb40e7bdfab8021f132f67b35aac';
  static const String _baseUrl = 'https://api.convertio.co';

  static Future<File?> convertXlsToXlsx(File xlsFile) async {
    try {
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
      if (initData['code'] != 200) {
        print('❌ Errore creazione job: ${initData['error']}');
        return null;
      }

      final jobId = initData['data']['id'];
      final filename = xlsFile.uri.pathSegments.last;
      print('📤 Job creato: $jobId');

      final uploadUrl = '$_baseUrl/convert/$jobId/$filename';
      final fileBytes = await xlsFile.readAsBytes();

      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': 'application/octet-stream',
        },
        body: fileBytes,
      );

      if (uploadResponse.statusCode != 200) {
        print('❌ Errore upload file: ${uploadResponse.statusCode}');
        return null;
      }

      print('📁 File caricato correttamente');

      while (true) {
        await Future.delayed(const Duration(seconds: 2));

        final statusResponse = await http.get(
          Uri.parse('$_baseUrl/convert/$jobId/status'),
        );

        final statusData = jsonDecode(statusResponse.body);

        if (statusData['code'] != 200 || statusData['data'] == null) {
          print('❌ Errore polling: ${statusData['error'] ?? statusData}');
          return null;
        }

        final step = statusData['data']['step'];
        final output = statusData['data']['output'];

        if (step == 'error') {
          print('❌ Job fallito: ${statusData['data']}');
          return null;
        }

        if (step == 'finish' && output != null && output['url'] != null) {
          final downloadUrl = output['url'];
          final downloadResponse = await http.get(Uri.parse(downloadUrl));

          final dir = await getTemporaryDirectory();
          final newFile = File('${dir.path}/${filename}.xlsx');
          await newFile.writeAsBytes(downloadResponse.bodyBytes);

          print('✅ File convertito salvato in: ${newFile.path}');
          return newFile;
        }

        print('⏳ Attendo conversione completata...');
      }
    } catch (e) {
      print('❌ Eccezione Convertio: $e');
      return null;
    }
  }
}
