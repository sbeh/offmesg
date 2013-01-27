library offmesg;

import 'dart:async';
import 'dart:json';
import 'dart:html';

class GlobalStorage {
  Function _got;

  GlobalStorage(got(List<String> globalMessages)) {
    _got = got;

    new HttpRequest.get('global.json', (request) {
      if(request.readyState == HttpRequest.DONE && request.status == 200)
        _got(parse(request.response));
    });
  }

  Future save(List<String> localMessages) {
    var completer = new Completer();

    var request = new HttpRequest();
    request.open('POST', 'global.dart');
    request.on.loadEnd.add((e) {
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
    request.setRequestHeader('Content-Type', 'application/json');
    request.send(stringify(localMessages));

    return completer.future;
  }
}