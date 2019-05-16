###
 * Federated Wiki : Social Security Plugin
 *
 * Licensed under the MIT license.
 * https://github.com/fedwiki/wiki-security-social/blob/master/LICENSE.txt
###

###
1. Display login button - if there is no authenticated user
2. Display logout button - if the user is authenticated

3. When user authenticated, claim site if unclaimed - and repaint footer.

###



update_footer = (ownerName, isAuthenticated) ->

  # we update the owner and the login state in the footer, and
  # populate the security dialog

  if ownerName
    $('footer > #site-owner').html("Site Owned by: <span id='site-owner' style='text-transform:capitalize;'>#{ownerName}</span>")

  $('footer > #security').empty()

  if isAuthenticated
    $('footer > #security').append "<a href='#' id='logout' class='footer-item' title='Sign-out'><i class='fas fa-lock-open fa-fw'></i></a>"
    $('footer > #security > #logout').click (e) ->
      e.preventDefault()
      myInit = {
        method: 'GET'
        cache: 'no-cache'
        mode: 'same-origin'
        credentials: 'include'
      }
      fetch '/logout', myInit
      .then (response) ->
        if response.ok
          window.isAuthenticated = false
          update_footer ownerName, false
        else
          console.log 'logout failed: ', response

  else
    if !isClaimed
      signonTitle = 'Claim this Wiki'
      $('footer > #security').append "<a href='#' id='show-security-dialog' class='footer-item' title='#{signonTitle}'><i class='fas fa-lock fa-fw'></i></a>"
      $('footer > #security > #show-security-dialog').click (e) ->
        myInit = {
          method: 'POST'
          cache: 'no-cache'
          mode: 'same-origin'
          credentials: 'include'
        }
        fetch '/login', myInit
        .then (response) ->
          console.log 'login response', response
          if response.ok
            response.json().then (json) ->
              ownerName = json.ownerName
              window.isClaimed = true
              window.isAuthenticated = true
              update_footer ownerName, true
          else
            console.log 'login failed: ', response
    else
      signonTitle = 'Reclaim this Wiki'
      $('footer > #security').append "<a href='#' id='show-security-dialog' class='footer-item' title='#{signonTitle}'><i class='fas fa-lock fa-fw'></i></a>"
      $('footer > #security > #show-security-dialog').click (e) ->
        reclaimMessage = "Welcome back #{ownerName}. Please enter your reclaim code to reconnect with your wiki."
        reclaimCode = ''
        reclaimCode = window.prompt(reclaimMessage)
        unless reclaimCode is ''
          data = new FormData()
          data.append( "json", JSON.stringify({reclaimCode: reclaimCode}))
          myInit = {
            method: 'POST'
            cache: 'no-cache'
            mode: 'same-origin'
            credentials: 'include'
            body: reclaimCode
          }
          fetch '/auth/reclaim/', myInit
          .then (response) ->
            console.log 'reclaim response', response
            if response.ok
              window.isAuthenticated = true
              update_footer ownerName, true
            else
              console.log 'reclaim failed: ', response



setup = (user) ->

  # we will replace font-awesome with a small number of svg icons at a later date...
  if (!$("link[href='/fontawesome/css/fontawesome.min.css']").length)
    $('<link rel="stylesheet" href="/security/fontawesome/css/fontawesome.min.css">
       <link rel="stylesheet" href="/security/fontawesome/css/solid.min.css">').appendTo("head")

  if (!$("link[href='/security/style.css']").length)
    $('<link rel="stylesheet" href="/security/style.css">').appendTo("head")

  wiki.getScript '/security/modernizr-custom.js', () ->
    unless Modernizr.promises
      require('es6-promise').polyfill()

    unless Modernizr.fetch
      require('whatwg-fetch')

    update_footer ownerName, isAuthenticated

window.plugins.security = {setup, update_footer}
