class Party extends $D._DataRow
  add_status: (name) ->
    @status ?= []
    prev = @status.clone()

    if ['waiting', 'seated', 'left'].has name
      @status = @status.subtract ['waiting', 'seated', 'left']

    if @status.has name
      return

    @status.push name

    @trigger 'status:change', [@status, prev]

  remove_status: (name) ->
    @status ?= []
    prev = @status.clone()

    if not @status.has name
      return

    @status.remove name

    @trigger 'status:change', [@status, prev]
 
class Parties extends $D._DataLoader
  name: 'parties'
  model: Party

  add: (vals={}) ->
    vals.times ?= {}

    vals.times.add ?= new Date

    _convert_times = (times) ->
      for own name, time of times
        if Object.isDate time
          times[name] = time.toISOString()
        else if Object.isObject time or Object.isArray time
          _convert_times time

    _convert_times vals.times

    super vals

$D.parties = new Parties
$.when( $D.parties.init() ).then ->

  clear = ->
    $D.parties.ds.each (row) ->
      if not row.times?.add or Date.get_elapsed(row.times.add) > 60 * 12
        $D.parties.ds.remove row

  do clear

  setTimeout(->
    do clear
    document.location.reload()
  , (new Date).add(1).day().set({'hour': 4, 'minute': 30}).millisecondsFromNow())

  $D.parties.demo = ->
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
          times:
            add: (new Date).add(-time).minutes()
          phone: '2482298031'
          quoted_wait: 60
          alert_method: 'sms'
          status: ['waiting']
          notes: note

