class Parties extends $D._DataLoader
  name: 'parties'

  add: (vals={}) ->
    vals.add_time ?= new Date
    if typeof vals.add_time != 'string'
      vals.add_time = vals.add_time.toISOString()

    super vals
  
$D.parties = new Parties
$.when( $D.parties.init() ).then ->
  
  $D.parties.ds.each (row) ->
    # DOM adaptor doesn't seem to support find
    if row.add_time and Date.get_elapsed(row.add_time) > 60 * 24
      $D.parties.ds.remove row

  $D.parties.ds.all (rows) ->
    len = rows.length
    while len++ < 12
      fnames = ['John', 'Jane', 'Zack', 'Marshall', 'Dick']
      lnames = ['Smith', 'Bloom', 'Wright', 'Miller', 'Lombardi']

      name = fnames[Math.floor(Math.random() * 5)] + ' ' +
        lnames[Math.floor(Math.random() * 5)]

      size = Math.ceil(Math.random() * 12)
      time = Math.floor(Math.random() * 90)

      notes = ['Requests a quiet table', 'Drink: Martini extra olives', '']
      note = notes[Math.floor(Math.random() * 3)]

      $D.parties.add
        key: $D.parties.ds.uuid()
        name: name
        size: size
        add_time: (new Date).add(-time).minutes()
        phone: '2482298031'
        quoted_wait: 60
        alert_method: 'sms'
        status: 'waiting'
        notes: note

