ALCE = require 'alce'
extend = require 'extend-object'
fs = require 'fs'
path = require 'path'
require 'colors'

defaultConfig = require('./config')

checkMissing = (pack, config) ->
  if pack.private
    warnItems = config.warnOnPrivate
    required = config.requiredOnPrivate
  else
    warnItems = config.warn
    required = config.required

  required.forEach (key) ->
    if not pack[key]
      throw new Error(config.fileName + ' files must have a ' + key)

  warnItems.forEach (key) ->
    if not pack[key] and not config.quiet
      console.log ('missing ' + key).yellow

sortAlphabetically = (object) ->
  if Array.isArray(object)
    object.sort((a, b) -> if a is b then 0 else if a > b then 1 else -1)
    return object
  else
    sorted = {}
    keys = Object.keys(object).sort(
      (a, b) -> if a is b then 0 else if a > b then 1 else -1
    )
    for key in keys
      sorted[key] = object[key]
    return sorted

module.exports = (file, config) ->
  config = extend(defaultConfig, config or {})
  if not fs.existsSync(file)
    if not config.quiet
      console.log ('No such file: ' + file).red
    process.exit 1

  config.fileName = path.basename(file)
  original = fs.readFileSync(file, encoding: 'utf8')
  pack = ALCE.parse(original)
  out = {}
  outputString = ''

  # make sure we have everything
  checkMissing pack, config

  # handle the specific ones we want, then remove
  config.sortToTop.forEach (key) ->
    if pack[key]
      out[key] = pack[key]
    delete pack[key]

  # sort the remaining
  pack = sortAlphabetically(pack)

  # add in the sorted ones
  for key of pack
    out[key] = pack[key]

  # sort some sub items alphabetically
  config.sortedSubItems.forEach (key) ->
    if out[key]
      out[key] = sortAlphabetically(out[key])

  # write it out
  outputString = JSON.stringify(out, null, 2) + '\n'
  if outputString isnt original
    fs.writeFileSync file, outputString, encoding: 'utf8'
    if not config.quiet
      console.log config.fileName.bold + ' fixed'.green + '!'
  else
    if not config.quiet
      console.log config.fileName.bold + ' already clean'.green + '!'
