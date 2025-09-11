import 'dart:async';
import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/progress.dart';
import 'package:nmeeting/repository/document-repository.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class DocumentBloc extends BaseBloc {
  // repository
  final _documentRepository = new DocumentRepository();

  // meeting Id
  final _meetingIdController = BehaviorSubject<String>();
  Stream<String> get meetingIdStream => _meetingIdController.stream;

  // progress Id
  final _progressIdController = BehaviorSubject<String>();
  Stream<String> get progressIdStream => _progressIdController.stream;

  // controller
  var _documentListStreamController =
      StreamController<List<DocumentOutput>>.broadcast();
  Stream<List<DocumentOutput>> get documentListStream =>
      _documentListStreamController.stream.asBroadcastStream();

  // controller
  var _libraryListStreamController = StreamController<List<LibraryOutput>>();
  Stream<List<LibraryOutput>> get libraryListStream =>
      _libraryListStreamController.stream;

  List<LibraryOutput> _libraryListOrigin = [];

  onSetMeetingId(String _id) {
    _meetingIdController.sink.add(_id);
  }

  onSetProgressId(String _id) {
    _progressIdController.sink.add(_id);
  }

  getDocuments(bool _isGetAll) async {
    final _documentInput = DocumentInput(
        progressID: _progressIdController.value,
        meetingID: _meetingIdController.value,
        isGetAll: _isGetAll);

    final res = await _documentRepository.getDocuments(_documentInput);
    if (res.status == 1) {
      _documentListStreamController.sink.add(res.data);
    } else {
      _documentListStreamController.sink.add([]);
    }
  }

  Future<TResult> getUrlDocumentByID(String _documentID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final _documentInput = UrlDocumentInput(
        documentID: _documentID,
        personalID: prefs.getString('personalID'),
        fullName: prefs.getString('fullname'));

    final res = await _documentRepository.getUrlDocumentByID(_documentInput);
    return res;
  }

  getDocumentByPersonalID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _libraryInput =
        LibraryInput(personalID: prefs.getString('personalID'));

    final res =
        await _documentRepository.getDocumentByPersonalID(_libraryInput);
    if (res.status == 1) {
      final _data = List<LibraryOutput>.from(res.data);
      _libraryListStreamController.sink.add(_data);
      _libraryListOrigin =
          _data.map((item) => new LibraryOutput.clone(item)).toList();
    } else {
      _libraryListStreamController.sink.add([]);
      _libraryListOrigin = [];
    }
  }

  search(String _searchText) {
    if (StringUtils.isNullOrEmpty(_searchText)) {
      _libraryListStreamController.sink.add(_libraryListOrigin);
      return;
    }

    var _result = _libraryListOrigin
        .where((test) =>
            (test.name!.toLowerCase().contains(_searchText.toLowerCase()) &&
                test.isDateGroup != true))
        .toList();

    if (_result.length == 0) {
      _libraryListStreamController.sink.add(_result);
    } else {
      // add date group
      List<LibraryOutput> finalRes = [];
      String dateGroup = _result.first.inDateGroup!;
      finalRes.add(new LibraryOutput(
          id: '',
          name: dateGroup,
          isDateGroup: true,
          isAllowDownload: false,
          inDateGroup: ''));
      for (var item in _result) {
        if (item.inDateGroup!.substring(0, 10) == dateGroup.substring(0, 10)) {
          finalRes.add(new LibraryOutput(
              id: item.id,
              name: item.name,
              isDateGroup: false,
              isAllowDownload: item.isAllowDownload,
              inDateGroup: item.inDateGroup));
        } else {
          dateGroup = item.inDateGroup!;
          finalRes.add(new LibraryOutput(
              id: '',
              name: dateGroup,
              isDateGroup: true,
              isAllowDownload: false,
              inDateGroup: ''));
          finalRes.add(new LibraryOutput(
              id: item.id,
              name: item.name,
              isDateGroup: false,
              isAllowDownload: item.isAllowDownload,
              inDateGroup: item.inDateGroup));
        }
      }
      _libraryListStreamController.sink.add(finalRes);
    }
  }

  Future<IOWebSocketChannel> openProgressWebSocketChannel() {
    return _documentRepository.openProgressWebSocketChannel();
  }

  @override
  void dispose() {
    _meetingIdController?.close();
    _progressIdController?.close();
    _documentListStreamController?.close();
    _libraryListStreamController?.close();
  }
}
