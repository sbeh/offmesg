import 'dart:html';
import 'dart:async';

import 'lib/local_storage_list.dart';

void main() {
  ButtonElement localSave = query('#localSave');
  ButtonElement localClear = query('#localClear');
  DivElement localMessages = query('#localMessages');
  TextAreaElement message = query('#message');

  var localList = new LocalStorageList('local');

  localList.asList.forEach((m) => addMessageToDOM(localMessages, m));
  localClear.disabled = localList.asList.isEmpty;

  localSave.on.click.add((e) {
    if(!message.value.trim().isEmpty)
      localList.add(message.value.trim());
    else {
      message.value = '';
      localSave.disabled = true;
    }
  });

  localList.on('add', (m) {
    addMessageToDOM(localMessages, m);

    message.value = '';
    localSave.disabled = true;

    localClear.disabled = false;
  });

  localClear.on.click.add((e) {
    localList.clear();
  });

  localList.on('clear', () {
    localMessages.children.clear();
    localClear.disabled = true;
  });

  new Timer.repeating(500, (t) {
    localSave.disabled = message.value.trim().isEmpty;
  });
}

addMessageToDOM(DivElement container, String message) {
  message = message.replaceAll(new RegExp('\\r?\\n'), '<br>');

  var child = new DivElement();
  child.classes.add('message');
  child.innerHtml = message;

  container.children.add(child);
}