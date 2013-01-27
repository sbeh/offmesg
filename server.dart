import 'dart:io';
import 'dart:json';

import 'web/global.dart';

HttpServer server;
var basePath = '/path/to/offmesg/web/';

handleGet(HttpRequest request, HttpResponse response) {
  String path = request.path == '/' ? 'index.html' : request.path.substring(1);
  File file = new File('${basePath}${path}');
  file.exists().then((found) {
    if (found)
      file.fullPath().then((fullPath) {
        if (fullPath.startsWith(basePath)) {
          if(fullPath.endsWith('.css'))
            response.headers.contentType = new ContentType('text', 'css');
          else if(fullPath.endsWith('.js'))
            response.headers.contentType = new ContentType('text', 'javascript');
          else if(fullPath.endsWith('.dart'))
            response.headers.contentType = new ContentType('application', 'dart');
          else if(fullPath.endsWith('.json'))
            response.headers.contentType = new ContentType('application', 'json');
          var s = file.openInputStream();
          s.onError = print;
          s.pipe(response.outputStream);
        } else
          serverError(null, HttpStatus.NOT_FOUND, response);
      }, onError: (error) => serverError(error, HttpStatus.INTERNAL_SERVER_ERROR, response));
    else
      serverError(null, HttpStatus.NOT_FOUND, response);
  }, onError: (error) => serverError(error, HttpStatus.INTERNAL_SERVER_ERROR, response));
}

main() {
  server = new HttpServer();
  server.addRequestHandler((request) {
    var log = new StringBuffer();
    log.add('${request.connectionInfo.remoteHost}:${request.connectionInfo.remotePort} > ');
    log.add('${request.method} http://${request.headers.host}');
    if(request.headers.port != 80)
      log.add(':${request.headers.port}');
    log.add(request.path);
    if(request.method == 'POST')
      log.add(' [${request.contentLength}bytes of ${request.headers.contentType}]');
    print(log);

    return false;
  }, null);
  server.addRequestHandler(
      (request) =>
          request.method == 'POST' &&
          new RegExp('^/?global.dart\$').hasMatch(request.path),
      (request, response) =>
          handleGlobalPost(basePath, request, response));
  server.addRequestHandler((request) => request.method == 'GET', handleGet);
  server.defaultRequestHandler = (request, response) =>
      serverError(request, HttpStatus.NOT_IMPLEMENTED, response);
  server.listen('127.0.0.1', 8081);
}

serverError(error, int status, HttpResponse response) {
  if(error != null)
    print(error);

  response.statusCode = status;
  response.outputStream.onClosed = () =>
      print(' Finished with HTTP Status ${status}');
  response.outputStream.close();
}