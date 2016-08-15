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
    $('footer > #security').append "<a href='#' id='logout' class='footer-item' title='Sign-out'><i class='fa fa-unlock fa-lg fa-fw'></i></a>"
    $('footer > #security > #logout').click (e) ->
      # log the user out...

  else
    if !isClaimed
      signonTitle = 'Claim this Wiki'
      $('footer > #security').append "<a href='#' id='show-security-dialog' class='footer-item' title='#{signonTitle}'><i class='fa fa-lock fa-lg fa-fw'></i></a>"
      $('footer > #security > #show-security-dialog').click (e) ->
        # code to claim with wiki - just call to /login
    else
      signonTitle = 'Wiki already claimed'
      $('footer > #security').append "<a href='#' id='show-security-dialog' class='footer-item' title='#{signonTitle}'><i class='fa fa-lock fa-lg fa-fw'></i></a>"



setup = (user) ->

  # we will replace font-awesome with a small number of svg icons at a later date...
  if (!$("link[href='https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css']").length)
    $('<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">').appendTo("head")

  if (!$("link[href='/security/style.css']").length)
    $('<link rel="stylesheet" href="/security/style.css">').appendTo("head")

  update_footer ownerName, isAuthenticated

window.plugins.security = {setup, update_footer}
