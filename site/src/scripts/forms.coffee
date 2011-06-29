$ ->
  $('#add-button').click ->
    el = $ '<li></li>'
    link = $ '<a></a>'
    el.append link

    e_time = $ '<span class="time">0 min</span>'
    link.append e_time

    name = $('#name').val()
    link.append name

    size = $('#party_size').val()

    e_size = $ '<span class="ui-li-count"></span>'
    e_size.text size
    link.append e_size

    $('#divider-010').after el
    
    if $('#queue-list').jqmData 'listview'
      $('#queue-list').listview 'refresh'

    $('#add_party').dialog 'close'
