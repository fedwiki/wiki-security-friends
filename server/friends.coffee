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
seedrandom = require 'seedrandom'


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

  nickname = (seed) ->
    rn = seedrandom(seed)
    c = "bcdfghjklmnprstvwy"
    v = "aeiou"
    ch = (string) -> string.charAt Math.floor rn() * string.length
    ch(c) + ch(v) + ch(c) + ch(v) + ch(c) + ch(v)


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
      return true
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
        secret = require('crypto').randomBytes(32).toString('hex')
        req.session.friend = secret
        nick = nickname secret
        id = {name: nick, friend: {secret: secret}}
        setOwner id, (err) ->
          if err
            console.log 'Failed to claim wiki ', req.hostname, 'error ', err
            res.sendStatus(500)
          updateOwner getOwner
          res.json({
            ownerName: nick
            })
          res.end
      else
        console.log 'friend returning login'
        res.sendStatus(501)

  security.logout = () ->
    (req, res) ->
      req.session.reset()
      res.send("OK")

  security.reclaim = () ->
    (req, res) ->
      reclaimCode = ''
      req.on('data', (chunk) ->
        reclaimCode += chunk.toString())

      req.on('end', () ->
        try
          if owner.friend.secret is reclaimCode
            req.session.friend = owner.friend.secret
            res.end()
          else
            res.sendStatus(401)
        catch error
          res.sendStatus(500))

  security.defineRoutes = (app, cors, updateOwner) ->
    app.post '/login', cors, security.login(updateOwner)
    app.get '/logout', cors, security.logout()
    app.post '/auth/reclaim/', cors, security.reclaim()

  security
