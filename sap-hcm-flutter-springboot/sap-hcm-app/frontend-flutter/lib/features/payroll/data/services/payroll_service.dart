import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';

class PayrollDocument {
  PayrollDocument({required this.bytes, required this.fileName, required this.mimeType});

  final List<int> bytes;
  final String fileName;
  final String mimeType;
}

class PayrollService {
  PayrollService(this._api);
  final ApiClient _api;

  Future<List<Map<String, dynamic>>> all() async => _list('/payroll');
  Future<List<Map<String, dynamic>>> my() async => _list('/payroll/my');
  Future<Map<String, dynamic>> detail(int id) async => Map<String, dynamic>.from(await _api.get('/payroll/$id'));
  Future<PayrollDocument> download(int id) async {
    try {
      final response = await _api.dio.get<List<int>>(
        '/payroll/$id/download',
        options: Options(responseType: ResponseType.bytes),
      );
      return PayrollDocument(
        bytes: response.data ?? <int>[],
        fileName: _fileNameFromDisposition(response.headers.value('content-disposition')) ?? 'fiche-paie-$id.pdf',
        mimeType: response.headers.value('content-type') ?? 'application/pdf',
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<Map<String, dynamic>>> _list(String path) async {
    final data = await _api.get(path);
    return List<Map<String, dynamic>>.from((data as List).map((e) => Map<String, dynamic>.from(e)));
  }

  String? _fileNameFromDisposition(String? disposition) {
    if (disposition == null || disposition.isEmpty) return null;
    final match = RegExp('filename="?([^";]+)"?').firstMatch(disposition);
    return match?.group(1);
  }
}
