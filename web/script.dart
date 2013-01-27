import 'dart:html';
import 'dart:async';

import 'lib/global_storage.dart';
import 'lib/local_storage_list.dart';

void main() {
  ButtonElement globalSave = query('#globalSave');
  ButtonElement globalClear = query('#globalClear');
  DivElement globalMessages = query('#globalMessages');

  ButtonElement localSave = query('#localSave');
  ButtonElement localClear = query('#localClear');
  DivElement localMessages = query('#localMessages');
  TextAreaElement message = query('#message');

  var localList = new LocalStorageList('local');

  localList.asList.forEach((m) => addMessageToDOM(localMessages, m));
  localClear.disabled = localList.asList.isEmpty;
  globalSave.disabled = localList.asList.isEmpty;

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
    globalSave.disabled = false;
  });

  localClear.on.click.add((e) {
    localList.clear();
  });

  localList.on('clear', () {
    localMessages.children.clear();
    localClear.disabled = true;
    globalSave.disabled = true;
  });

  var globalList = new LocalStorageList('global');

  globalList.asList.forEach((m) => addMessageToDOM(globalMessages, m));
  globalClear.disabled = globalList.asList.isEmpty;

  var globalStorage = new GlobalStorage((ms) {
    globalList.clear();
    ms.forEach((m) => globalList.add(m));
  });
  globalStorage.get();

  globalSave.on.click.add((MouseEvent event) {
    globalStorage.save(localList.asList).then((e) {
      localList.asList.forEach((m) {
        globalList.add(m);
      });
      localList.clear();
    }, onError: (e) => showErrorViaDOM(event.toElement, e.error));
  });

  globalList.on('add', (m) {
    addMessageToDOM(globalMessages, m);

    globalClear.disabled = false;
  });

  globalClear.on.click.add((MouseEvent event) {
    globalStorage.clear().then(
        (e) => globalList.clear(),
        onError: (e) => showErrorViaDOM(event.toElement, e.error));
  });

  globalList.on('clear', () {
    globalMessages.children.clear();
    globalClear.disabled = true;
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

showErrorViaDOM(Element element, error) {
  print(error);

  var overlay = new DivElement();
  overlay.style.position = 'absolute';
  overlay.style.top = '${element.getBoundingClientRect().top}px';
  overlay.style.left = '${element.getBoundingClientRect().left}px';
  overlay.style.height = '${element.getBoundingClientRect().height}px';
  overlay.style.width = '${element.getBoundingClientRect().width}px';
  overlay.style.backgroundColor = 'rgb(255,0,0)';

  var opacity = .6;
  overlay.style.opacity = opacity.toString();
  new Timer.repeating(80, (t) {
    opacity -= .1;

    if(opacity > 0)
      overlay.style.opacity = opacity.toString();
    else {
      t.cancel();
      overlay.remove();
    }
  });

  document.body.children.add(overlay);
}