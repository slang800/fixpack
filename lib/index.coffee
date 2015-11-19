ALCE = require 'alce'
correctLicense = require 'spdx-correct'
spdx = require 'spdx'

config =
  sortToTop: [
    'name'
    'description'
    'version'
    'author'
  ]
  required: [
    'name'
    'version'
  ]
  warn: [
    'description'
    'author'
    'repository'
    'keywords'
    'main'
    'bugs'
    'homepage'
    'license'
  ]
  warnOnPrivate: [
    'name'
    'version'
    'description'
    'main'
  ]
  sortedSubItems: [
    'dependencies'
    'devDependencies'
    'peerDependencies'
    'optionalDependencies'
    'jshintConfig'
    'scripts'
    'keywords'
  ]

# list of mispellings of the word "license", extracted from field totals in the
# npm database
LICENSE_MISPELLINGS = [
  'licence'
  'licencse'
  'licensce'
  'license:'
  'licese'
  'licnense'
  'liecnse'
  'lincense'
  'linsence'
  'liscense'
  'lisence'
]

checkMissing = (pack, {log}) ->
  required = config.required
  warnItems = (
    if pack.private
      config.warnOnPrivate
    else
      config.warn
  )

  for key in required
    if not pack[key]
      throw new Error("missing required key: #{key}")

  for key in warnItems
    if not pack[key]
      log "missing: #{key}"

fixLicense = (pack, {log}) ->
  if pack.licenses?
    log 'invalid key \'licenses\' found, not fixing'

  if not pack.license?
    for key, value of pack
      if key.toLowerCase() in LICENSE_MISPELLINGS
        log "mispelled key '#{key}' found, corrected to 'license'"
        pack.license = value
        delete pack[key]
        break

  if pack.license? and pack.license isnt 'UNLICENSED' and
     not spdx.valid(pack.license)
    corrected = correctLicense(pack.license)
    log "invalid SPDX license expression '#{pack.license}', corrected
    to '#{corrected}'"
    pack.license = corrected

  if not pack.license?
    log "license field missing - defaulting to 'UNLICENSED' (disallows
    others from using this module)"
    pack.license = 'UNLICENSED'

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

module.exports = (originalContent, {log}) ->
  pack = ALCE.parse(originalContent)
  out = {}
  outputString = ''

  # make sure we have everything
  checkMissing pack, {log}
  fixLicense(pack, {log})

  # handle the specific ones we want, then remove
  for key in config.sortToTop
    if pack[key]
      out[key] = pack[key]
    delete pack[key]

  # sort the remaining
  pack = sortAlphabetically(pack)

  # add in the sorted ones
  for key of pack
    out[key] = pack[key]

  # sort some sub items alphabetically
  for key in config.sortedSubItems
    if out[key] then out[key] = sortAlphabetically(out[key])

  JSON.stringify(out, null, 2) + '\n'
