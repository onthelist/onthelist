winston = require './winston'

# Each process has a logger and file.
# Libs have loggers, but log into the parent process' file.

wrap_logger = (logger) ->
  if not logger.log_req?
    logger.log_req = (req, msg, meta={}) ->
      meta['host'] = req.headers.host
      meta['orig_host'] = req.headers['x-forwarded-for']

      logger.info msg, meta

  return logger

add_process_logger = (name) ->
  out_name = "ss-#{name}"

  process.title = out_name

  file = "/home/www-server/logs/#{out_name}.log"

  winston.add winston.transports.File,
    filename: file
    handleExceptions: true

  winston.remove winston.transports.Console
  winston.add winston.transports.Console,
    handleExceptions: true

  winston.handleExceptions()

  return wrap_logger winston

add_logger = (name) ->
  winston.loggers.add name

  return wrap_logger winston.loggers.get name

loggers = {}
module.exports.get_logger = (name) ->
  if not name?
    return wrap_logger winston

  if not loggers[name]?
    if not module.parent?.parent?
      # We are being called from the file being executed.
      # Note that if the file being executed does not import logging,
      # none of the process logging init will take place.

      loggers[name] = add_process_logger name
    else
      loggers[name] = add_logger name

  return loggers[name]
