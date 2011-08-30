$ ->
  $('[data-role=page]').bind 'pageshow', ->
    # Does not bind dialogs
    
    $head = $('h1[data-key=page_title]', this)

    if $D.device.get('registered')
      $head.text $D.device.get('display_organization')

    else
      $head.html 'Local Mode - <a href="#register_device">Register Device</a>'

    true
