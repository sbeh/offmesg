import 'dart:html';
import 'dart:async';

void main() {
  ButtonElement localSave = query('#localSave');
  ButtonElement localClear = query('#localClear');
  DivElement localMessages = query('#localMessages');
  TextAreaElement message = query('#message');

  localSave.on.click.add((e) {
    if(!message.value.trim().isEmpty) {
      var m = message.value.trim();
      m = m.replaceAll(new RegExp('\\r?\\n'), '<br>');

      var child = new DivElement();
      child.classes.add('message');
      child.innerHtml = m;

      localMessages.children.add(child);
      localClear.disabled = false;
    }

    message.value = '';
    localSave.disabled = true;
  });

  localClear.on.click.add((e) {
    localMessages.children.clear();
    localClear.disabled = true;
  });

  new Timer.repeating(500, (t) {
    localSave.disabled = message.value.trim().isEmpty;
  });
}