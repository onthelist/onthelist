$('[data-role=page]').live 'pagebeforeshow', ->
  hash = '#' + this.getAttribute 'id'

  $('[data-role=navbar] a')
    .removeClass('ui-btn-active')
    .filter('[href=' + hash + ']')
      .addClass('ui-btn-active ui-state-persist')
