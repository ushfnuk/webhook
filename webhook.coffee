http   = require 'http'
https  = require 'https'
url    = require 'url'
path   = require 'path'
_      = require 'underscore'
config = require('./config')


PREFIX = path.join (config.prefix || ''), '/repos'
INFIX  = path.join config.user, config.repo


defaultHeaders =
    Authorization: "token #{config.access_token}"
    Accept: 'application/vnd.github.v3+json'
    'User-Agent': 'Webhook'

setHeaders = (headers)->
    return _.extend defaultHeaders, headers


server = http.createServer()
server.on 'connection', (socket)->
    socket.setNoDelay true
    socket.setKeepAlive true


server.on 'request', (req, res)->
    uri      = url.parse req.url
    pathname = uri.pathname

    headers = setHeaders {}

    if pathname is '/favicon.ico'
        res.end()
        return

    if pathname is '/payload'
        options =
            hostname: config.hostname
            method: 'POST'
            path: path.join PREFIX, INFIX, "pulls"
            port: 443
            headers: headers

        data = ''
        req.on 'data', (chunk)->
            data += chunk

        req.on 'end', ->
            data = data.toString()
            json = JSON.parse data

            refParts = json.ref.split('/')
            user     = json.pusher.name
            branch   = refParts[refParts.length - 1]

            request = https.request options, (response)->
                data = ''
                response.on 'data', (chunk)->
                    data += chunk

                response.on 'end', ->
                    console.log "response = #{data.toString()}"
                    res.end()

            post = JSON.stringify
                title: "Pull request для #{branch}"
                base: 'master'
                head: "#{user}:#{branch}"

            console.log "post = #{post}"

            request.end post

    else
        res.writeHead 404, 'Content-Type': 'text/html'
        res.end '<h1>Страница не найдена</h1>'

port = Number(process.env.PORT || 8000)

server.listen port

console.log "listen on port #{port}"
