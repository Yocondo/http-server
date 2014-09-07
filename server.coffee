express = require 'express'
logger = require 'winston'

sendError = (res, err) ->
	logger.error '[httpd]', err.stack || err
	res.status err.code || 500
	res.header 'Content-Type', 'text/plain'
	res.send err.stack || err

reply = (res, promise) ->
	promise
	.then (data) ->
		res.send data
	.catch (err) ->
		sendError res, err

module.exports = (options) ->
	app = express()
	app.use require('compression')()

	{
		server: app

		controller: (method, pattern, handler) ->
			logger.info '[httpd] registering controller at %s %s', method.toUpperCase(), pattern
			app[method.toLowerCase()] pattern, (req, res) ->
				try
					promise = handler(req, res)
					reply res, promise
				catch err
					sendError res, err

		start: ->
			port = options.port || 3000
			app.listen port, ->
				logger.info '[httpd] running at port %s', options.port
	}
