library offmesg;

import 'dart:async';
import 'dart:json';
import 'dart:html';

class GlobalStorage {
  Function _got;

  GlobalStorage(got(List<String> globalMessages)) {
    _got = got;
  }

  get() {
    new HttpRequest.get('global.json', (request) {
      if(request.readyState == HttpRequest.DONE && request.status == 200)
        _got(parse(request.response));
    });
  }

  Future _post(data, loadEnd(event, HttpRequest request, Completer completer)) {
    var completer = new Completer();

    var request = new HttpRequest();
    request.open('POST', 'global.dart');
    request.on.loadEnd.add((e) => loadEnd(e, request, completer));
    if(data is String)
      request.send(data);
    else {
      request.setRequestHeader('Content-Type', 'application/json');
      request.send(stringify(data));
    }

    return completer.future;
  }

  Future save(List<String> localMessages) {
    return _post(localMessages, (e, request, completer) {
      if(request.readyState == HttpRequest.DONE &&
         request.status == 200 &&
         request.response == 'ACK')
        completer.complete();
      else
        completer.completeError('''
Sending local messages to server failed:
  Status: ${request.status}
  Content: '${request.response}'
''');
    });
  }

  clear() {
    return _post('CLEAR', (e, request, completer) {
      if(request.readyState == HttpRequest.DONE &&
         request.status == 200 &&
         request.response == 'ACK')
        completer.complete();
      else
        completer.completeError('''
Sending CLEAR command to server failed:
  Status: ${request.status}
  Content: '${request.response}'
''');
    });
  }
}