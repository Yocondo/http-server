express = require 'express'
logger = require 'winston'

reply = (res, promise) ->
	promise
	.then (data) ->
		res.send data
	.catch (err) ->
		logger.error err.stack || err
		res.send err.code || 500, err

module.exports = (options) ->
	app = express()
	app.use require('compression')()

	{
		server: app

		controller: (method, pattern, handler) ->
			logger.info '[httpd] registering controller at %s %s', method.toUpperCase(), pattern
			app[method.toLowerCase()] pattern, (req, res) -> reply res, handler(req, res)

		start: ->
			port = options.port || 3000
			app.listen port, ->
				baseUrl = options.baseUrl || "http://localhost:#{port}"
				logger.info '[httpd] running at port %s', baseUrl
	}
