Events associated with objects (parties, tables, etc.)
Can trigger actions
Change state of object
Logged

e.g. bind event to "party state +seated" or "party waiting time > 30 min"
Time events poll every minute?
Repeating or one shot

Propagate through client-side js and server-side apps, triggered on both?

On server, two classes of objects:

  - Live
    - Stored in CDB
    - Sunc to clients
    - Has events
  - Archive
    - Stored in CDB, Mongo, RDS?
    - Used for analytics
    - No events

Use map in CDB, same code on client. 
  +A little live processing for mutable stuff (e.g. time)

Server-side actions (e.g. SMS) done by server code, client-side actions (e.g.
local alert) done by client-side trigger.

Server actions stored in org or location doc, client actions stored in
settings.

