###
 * Federated Wiki : Node Server
 *
 * Copyright Ward Cunningham and other contributors
 * Licensed under the MIT license.
 * https://github.com/fedwiki/wiki-node-server/blob/master/LICENSE.txt
###
# **security.coffee**
# Module for default site security.
#
# This module is not intented for use, but is here to catch a problem with
# configuration of security. It does not provide any authentication, but will
# allow the server to run read-only.

#### Requires ####
console.log 'friends starting'
fs = require 'fs'


# Export a function that generates security handler
# when called with options object.
module.exports = exports = (log, loga, argv) ->
  security = {}

  #### Private utility methods. ####

  user = ''

  owner = ''

  admin = argv.admin

  # save the location of the identity file
  idFile = argv.id

  #### Public stuff ####

  # Retrieve owner infomation from identity file in status directory
  # owner will contain { name: <name>, friend: {secret: '...'}}
  security.retrieveOwner = (cb) ->
    fs.exists idFile, (exists) ->
      if exists
        fs.readFile(idFile, (err, data) ->
          if err then return cb err
          owner = JSON.parse(data)
          cb())
      else
        owner = ''
        cb()

  # Return the owners name
  security.getOwner = ->
    if !owner.name?
      ownerName = ''
    else
      ownerName = owner.name
    ownerName

  security.setOwner = setOwner = (id, cb) ->
    owner = id
    fs.exists idFile, (exists) ->
      if !exists
        fs.writeFile(idFile, JSON.stringify(id, null, "  "), (err) ->
          if err then return cb err
          console.log "Claiming site for ", id:id
          owner = id
          cb())
      else
        cb()


  security.getUser = (req) ->
    if req.session.friend
      return req.session.friend
    else
      return ''

  security.isAuthorized = (req) ->
    try
      if req.session.friend is owner.friend.secret
        return true
      else
        return false
    catch error
      return false

  # Wiki server admin
  security.isAdmin = (req) ->
    if req.session.friend is admin
      return true
    else
      return false

  security.login = (updateOwner) ->
    (req, res) ->
      console.log 'friend login',
        secret:req.secret
        cookies:req.cookies
        params:req.params
        query:req.query
        headers:req.headers
        body:req.body

      if owner is '' # site is not claimed
        # create a secret and write it to owner file and the cookie
        secret = require('crypto').randomBytes(64).toString('hex')
        console.log 'login req session', req.session
        req.session.friend = secret
        res.body = {name: 'a friend', friend: {secret: secret}}
      else
        console.log 'friend returning login'

      res.send("OK")

  security.reclaim = () ->
    (req, res) ->
      ###
        check reclaim code is valid
        if not valid ignore request and exit
        if valid create cookie with secret and redirect to wiki site
      ###
      console.log 'friends: reclaim'
      "ok"


  security.logout = () ->
  (req, res) ->
    console.log "friends: logout"

  security.defineRoutes = (app, cors, updateOwner) ->

    app.post '/login', cors, security.login(updateOwner)

    ### /auth/reclaim#df89usy6pew98ryb
    app.post '/auth/reclaim', cors, security.reclaim
    ###

    app.post '/logout', cors, (req, res) ->
      req.session.reset()
      security.logout()
      res.send("OK")

  console.log 'friends defined'
  security
