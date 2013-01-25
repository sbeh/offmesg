library offmesg;

import 'dart:html';

class LocalStorageList {
  String _prefix;

  LocalStorageList(this._prefix) {
    if(window.localStorage.containsKey('${_prefix}_length')) {
      _length = int.parse(window.localStorage['${_prefix}_length']);

      for(int i = 0; i < Length; ++i)
        assert(window.localStorage.containsKey('${_prefix}_${i}'));
    } else
      _Length(0);

    try {
      window.localStorage.keys.forEach((key) {
        if(key.startsWith('${_prefix}_')) {
          if(key == '${_prefix}_length')
            return;

          var i = int.parse(key.substring('${_prefix}_'.length));
          assert(i >= 0 && i < _length);
        }
      });
    } catch(e) {
      // TODO: Not supported by IE9
    }

    // TODO: Register for storage event to track
    //       changes across different browser tabs
  }

  // +manipulate
  add(String value) {
    window.localStorage['${_prefix}_${Length}'] = value;
    _Length(_length + 1);

    _added.forEach((call) {
      call(value);
    });
  }

  clear() {
    for(int i = 0; i < Length; ++i)
      window.localStorage.remove('${_prefix}_${i}');
    _Length(0);

    _cleared.forEach((call) {
      call();
    });
  }
  // -manipulate

  // +view
  int _length;
  _Length(int length) {
    _length = length;
    window.localStorage['${_prefix}_length'] = length.toString();
  }
  int get Length => _length;

  List<String> get asList {
    var list = new List<String>();
    for(int i = 0; i < Length; ++i)
      list.add(window.localStorage['${_prefix}_${i}']);
    return list;
  }
  // -view

  // +events
  List<Function> _added;
  List<Function> _cleared;
  on(String event, Function call) {
    List<Function> list;

    switch(event) {
      case 'add':
        if(_added == null)
          _added = new List<Function>();
        list = _added;
        break;

      case 'clear':
        if(_cleared == null)
          _cleared = new List<Function>();
        list = _cleared;
        break;

      default:
        throw new Exception('No such event: ${event}');
    }

    list.add(call);
  }
  // -events
}