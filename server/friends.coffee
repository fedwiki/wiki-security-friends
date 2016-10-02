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
  security.getOwner = getOwner = ->
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


      if owner is '' # site is not claimed
        # create a secret and write it to owner file and the cookie
        secret = require('crypto').randomBytes(64).toString('hex')
        console.log 'login req session', req.session
        req.session.friend = secret
        console.log 'login req session', req.session
        id = {name: 'a friend', friend: {secret: secret}}
        setOwner id, (err) ->
          if err
            console.log 'Failed to claim wiki ', req.hostname, 'error ', err
            res.sendStatus(500)
          updateOwner getOwner
          res.json({
            ownerName: 'a friend'
            })
          res.end
      else
        console.log 'friend returning login'
        res.sendStatus(501)



  security.reclaim = () ->
    (req, res) ->
      console.log 'param:', req.params.secret

      try
        if owner.friend.secret is req.params.secret
          req.session.friend = owner.friend.secret
          res.redirect('/view/welcome-visitors')
        else
          res.sendStatus(401)

      catch error
        res.sendStatus(500)



  security.logout = () ->
  (req, res) ->
    console.log "friends: logout"

  security.defineRoutes = (app, cors, updateOwner) ->

    app.post '/login', cors, security.login(updateOwner)

    # /auth/reclaim#df89usy6pew98ryb
    app.get '/auth/reclaim/:secret', cors, security.reclaim()


    app.post '/logout', cors, (req, res) ->
      req.session.reset()
      security.logout()
      res.send("OK")

  console.log 'friends defined'
  security
