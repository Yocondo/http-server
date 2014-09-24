// Generated by CoffeeScript 1.8.0
var express, logger, reply, sendError;

express = require('express');

logger = require('winston');

sendError = function(res, err) {
  logger.error('[httpd]', err.stack || err);
  res.status(err.code || 500);
  res.header('Content-Type', 'text/plain');
  return res.send(err.stack || err);
};

reply = function(res, promise) {
  return promise.then(function(data) {
    return res.send(data);
  })["catch"](function(err) {
    return sendError(res, err);
  });
};

module.exports = function(options) {
  var app;
  app = express();
  app.use(require('compression')());
  return {
    server: app,
    controller: function(method, pattern, handler) {
      logger.info('[httpd] registering controller at %s %s', method.toUpperCase(), pattern);
      return app[method.toLowerCase()](pattern, function(req, res) {
        var err, promise;
        try {
          promise = handler(req, res);
          return reply(res, promise);
        } catch (_error) {
          err = _error;
          return sendError(res, err);
        }
      });
    },
    "static": function(path) {
      return app.use(express["static"](path));
    },
    start: function() {
      var port;
      port = options.port || 3000;
      return app.listen(port, function() {
        return logger.info('[httpd] running at port %s', options.port);
      });
    }
  };
};
