var express = require('express');
var RedisStore = require('connect-redis')(express);

/**
 * Store is used to associate authentication tokens with
 * sessions.
 *
 * To fit our needs, a storage mechanism needs to associate
 * IDs with data and support get/set/delete with TTLs.
 *
 * Fortunatly, the Connect Stores (used for session support),
 * already implement those features, allowing us to use the
 * prexisting Store implementations to support any server
 * we wish.
 *
 * Redis is the prefered mechanism, as it will make supporting
 * sessions across multiple production servers possible, but
 * MemoryStore may be used for development.
 */

module.exports = new RedisStore();
//module.exports = new express.session.MemoryStore();
