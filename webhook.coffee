http  = require 'http'
https = require 'https'
url   = require 'url'
_     = require 'underscore'


ACCESS_TOKEN = 'token'  # свой access_token
USER         = 'ushfnuk'
REPO         = 'webhook'
HOSTNAME     = 'api.github.com'
PREFIX       = ''
INFIX        = "#{USER}/#{REPO}"


defaultHeaders =
    Authorization: "token #{ACCESS_TOKEN}"
    Accept: 'application/vnd.github.v3+json'

setHeaders = (headers)->
    return _.extend defaultHeaders, headers



server = http.createServer()
server.on 'connection', (socket)->
    socket.setNoDelay true
    socket.setKeepAlive true


server.on 'request', (req, res)->
    uri      = url.parse req.url
    pathname = uri.pathname
    regExp   = new RegExp "^#{PREFIX}\/repos\/#{INFIX}"

    delete req.headers.host

    headers = setHeaders {}

    options =
        hostname: HOSTNAME
        method: 'GET'
        path: pathname
        port: 443
        headers: headers

    if pathname is '/favicon.ico'
        res.end()
        return

    if pathname is '/payload'
        data = ''
        req.on 'data', (chunk)->
            data += chunk

        req.on 'end', ->
            console.log "data = #{data.toString()}"
            console.log "pathname = #{pathname}"
            res.end()

    else
        res.writeHead 404, 'Content-Type': 'text/html'
        res.end '<h1>Страница не найдена</h1>'

port = Number(process.env.PORT || 8000)

server.listen port

console.log "listen on port #{port}"
