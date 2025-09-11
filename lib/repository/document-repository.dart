import 'dart:convert';
import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/models/progress.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:web_socket_channel/io.dart';

class DocumentRepository {
  final _provider = ApiProvider();

  Future<TResult> getDocuments(DocumentInput data) async {
    final response =
        await _provider.post(api.URL_DOCUMENT_BY_PROGRESS_ID, jsonEncode(data));

    List<DocumentOutput> _documents = [];
    if (response['Status'] == 1) {
      final _documentsData = response['Data'].cast<Map<String, dynamic>>();
      _documents = _documentsData.map<DocumentOutput>((event) {
        return DocumentOutput.fromJson(event);
      }).toList();
    }

    return TResult(
        status: response['Status'], data: _documents, msg: response['Msg']);
  }

  Future<TResult> getUrlDocumentByID(UrlDocumentInput data) async {
    final response =
        await _provider.post(api.URL_URL_DOCUMENT_BY_ID, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg']);
  }

  Future<TResult> getDocumentByPersonalID(LibraryInput data) async {
    final response =
        await _provider.post(api.URL_DOCUMENT_BY_PERSONALID, jsonEncode(data));

    List<LibraryOutput> _documents = [];
    if (response['Status'] == 1) {
      final _documentsData = response['Data'].cast<Map<String, dynamic>>();
      _documents = _documentsData.map<LibraryOutput>((event) {
        return LibraryOutput.fromJson(event);
      }).toList();
    }

    return TResult(
        status: response['Status'], data: _documents, msg: response['Msg']);
  }

  Future<IOWebSocketChannel> openProgressWebSocketChannel() async {
    return _provider.openWebSocket(api.WS_URL_PROGRESS);
  }
}
