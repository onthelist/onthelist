class Party extends Backbone.Model
  initialize: ->
    if not @attributes.times?.add?
      @set
        times:
          add: new Date

    if not @attributes.status?
      @set
        status: ['waiting']

  set: (attr, opts) ->
    if attr.times?
      for own name, time of attr.times
        if typeof time != 'string'
          attr.times[name] = time.toISOString()

    super attr, opts

  update: (args...) ->
    @set args...

    # We save to local storage, so it has no real cost.
    if @localStorage or @collection?.localStorage
      do @save

class Parties extends Backbone.Collection
  model: Party
  localStorage: new Store 'parties'

  bindBack: (event, func, cxt=this) ->
    evts = event.split ' '

    if evts.has 'add'
      $D.parties.each (row) ->
        func.call cxt, row

    for evt in evts
      @bind evt, func, cxt

  getAsync: (id, func) ->
    func @get(id)
  
$D.parties = new Parties
do $D.parties.fetch

$D.parties.chain()
  .select (row) ->
    not row.get('times')?.add or Date.get_elapsed(row.get('times').add) > 60 * 2
  .each (row) ->
    $D.parties.remove row

len = $D.parties.length
while len++ < 12
  fnames = ['John', 'Jane', 'Zack', 'Marshall', 'Dick']
  lnames = ['Smith', 'Bloom', 'Wright', 'Miller', 'Lombardi']

  name = fnames[Math.floor(Math.random() * 5)] + ' ' +
    lnames[Math.floor(Math.random() * 5)]

  size = Math.ceil(Math.random() * 12)
  time = Math.floor(Math.random() * 90)

  notes = ['Requests a quiet table', 'Drink: Martini extra olives', '']
  note = notes[Math.floor(Math.random() * 3)]

  $D.parties.create
    id: $UUID()
    name: name
    size: size
    times:
      add: (new Date).add(-time).minutes()
    phone: '2482298031'
    quoted_wait: 60
    alert_method: 'sms'
    status: ['waiting']
    notes: note

