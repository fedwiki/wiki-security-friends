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
    $('footer > #site-owner').html("Wiki by: <span id='site-owner'>#{ownerName}</span>")

  $('footer > #security').empty()

  if isAuthenticated
    if isOwner
      $('footer > #security').append "<a href='#' id='logout' class='footer-item' title='Sign-out'><i class='fas fa-lock-open fa-fw'></i></a>"
    else
      $('footer > #security').append "<a href='#' id='logout' class='footer-item' title='Not Owner : Sign-out'><i class='fas fa-lock fa-fw notOwner'></i></a>"
    $('footer > #security > #logout').on 'click', (e) ->
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
      $('footer > #security > #show-security-dialog').on 'click', (e) ->
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
      $('footer > #security > #show-security-dialog').on 'click', (e) ->
        reclaimDialog = document.getElementById('reclaim')

        reclaimDialog.showModal()
        requestAnimationFrame ->
          reclaimEl = reclaimDialog.querySelector('#reclaimcode')
          reclaimEl.focus()
          # selecting the input text allows the user to easily overwrite an existing code
          reclaimEl.select()



setup = (user) ->

  # we will replace font-awesome with a small number of svg icons at a later date...
  if (!$("link[href='/fontawesome/css/fontawesome.min.css']").length)
    $('<link rel="stylesheet" href="/security/fontawesome/css/fontawesome.min.css">
       <link rel="stylesheet" href="/security/fontawesome/css/solid.min.css">').appendTo("head")

  if (!$("link[href='/security/style.css']").length)
    $('<link rel="stylesheet" href="/security/style.css">').appendTo("head")

  dialog = """
            <dialog id="reclaim">
              <form method="dialog" id="reclaim-form">
                <h1>Welcome back #{ownerName}.</h1>
                <p>Please enter your reclaim code.</p>
                <input type="password" id="reclaimcode" name="reclaim" autofocus required>
                <div>
                  <menu>
                    <li><button id="cancelBtn">Cancel</button></li>
                    <li><button id="confirmBtn">Submit</button></li>
                  </menu>
                </div>
              </form>
            </dialog>
           """
  if (!document.getElementById('reclaim'))
    $(dialog).appendTo("body")

    reclaimDialog = document.getElementById('reclaim')
    reclaimForm = reclaimDialog.querySelector('#reclaim-form')
    reclaimEl = reclaimDialog.querySelector('#reclaimcode')
    cancelBtn = reclaimDialog.querySelector('#cancelBtn')

    reclaimForm.addEventListener 'submit', (event) ->
      event.preventDefault()
      reclaimCode = reclaimEl.value

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
            window.isOwner = true
            update_footer ownerName, true
          else
            console.log 'reclaim failed: ', response
      reclaimDialog.close()

    cancelBtn.addEventListener 'click', (event) ->
      reclaimDialog.close()

  update_footer ownerName, isAuthenticated

window.plugins.security = {setup, update_footer}
