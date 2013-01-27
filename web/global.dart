library offmesg;

import 'dart:io';
import 'dart:json';

var basePath;

handleGlobalPost(String _basePath, HttpRequest request, HttpResponse response) {
  basePath = _basePath;

  var newMessages = new List<int>();
  request.inputStream.onData = () =>
      newMessages.addAll(request.inputStream.read());
  request.inputStream.onClosed = () {
    if(newMessages.length == 0) {
      print('No messages from client received.');
      return;
    }

    var f = new File('${basePath}global.json');
    f.exists().then((bool found) {
      if(found) {
        var s = f.openInputStream();
        var knownMessages = new List<int>();
        s.onError = (error) => fail(error, response);
        s.onData = () =>
            knownMessages.addAll(s.read());
        s.onClosed = () {
          knownMessages = new String.fromCharCodes(knownMessages);
          knownMessages = parse(knownMessages) as List<String>;

          newMessages = new String.fromCharCodes(newMessages);
          newMessages = parse(newMessages) as List<String>;
          newMessages.forEach((message) =>
              print('New message: ${message.
                replaceAll(new RegExp('\r?\n', multiLine: true),
                    '\\n')}'));

          knownMessages.addAll(newMessages);

          knownMessages = stringify(knownMessages);
          knownMessages = knownMessages.charCodes;

          save(knownMessages, response);
        };
      } else
        save(newMessages, response);
    }, onError: (error) => fail(error, response));
  };
}

save(List<int> messages, HttpResponse response) {
  var f = new File('${basePath}global.json');
  f.createSync();
  var s = f.openOutputStream(FileMode.WRITE);
  s.onError = (error) => fail(error, response);
  s.onClosed = success(response);
  s.write(messages);
  s.close();
}

fail(error, HttpResponse response) {
  print(error);

  response.outputStream.writeString('ERR');
  response.outputStream.close();
}

success(HttpResponse response) {
  response.outputStream.writeString('ACK');
  response.outputStream.close();
}