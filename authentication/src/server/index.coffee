http = require 'http'
path = require 'path'
express = require 'express'
gzippo = require 'gzippo'
derby = require 'derby'
app = require '../auth'
serverError = require './serverError'
MongoStore = require('connect-mongo')(express)
derbyAuth = require('../../derby-auth')

## SERVER CONFIGURATION ##

expressApp = express()
server = http.createServer expressApp
module.exports = server

derby.use(require 'racer-db-mongo')
store = derby.createStore
	db: {type: 'Mongo', uri: 'mongodb://localhost/derby-auth'}
	listen: server

ONE_YEAR = 1000 * 60 * 60 * 24 * 365
root = path.dirname path.dirname __dirname
publicPath = path.join root, 'public'

expressApp
	.use(express.favicon())
	# Gzip static files and serve from memory
	.use(gzippo.staticGzip publicPath, maxAge: ONE_YEAR)
	# Gzip dynamically rendered content
	.use(express.compress())

	# Uncomment to add form data parsing support
   .use(express.bodyParser())
   .use(express.methodOverride())

    # Uncomment and supply secret to add Derby session handling
    # Derby session middleware creates req.session and socket.io sessions
    .use(express.cookieParser())
  	.use(store.sessionMiddleware
      secret: process.env.SESSION_SECRET || 'YOUR SECRET HERE'
      cookie: {maxAge: ONE_YEAR}
      store: new MongoStore(url: 'mongodb://localhost/derby-auth')
    )

	# Adds req.getModel method
	.use(store.modelMiddleware())

	# Middelware can be inserted after the modelMiddleware and before
  # the app router to pass server accessible data to a model
  .use(derbyAuth.middleware(expressApp, store))

	# Creates an express middleware from the app's routes
	.use(app.router())
	.use(expressApp.router)
	.use(serverError root)


## SERVER ONLY ROUTES ##

expressApp.all '*', (req) ->
	throw "404: #{req.url}"
