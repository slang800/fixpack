ALCE = require 'alce'
correctLicense = require 'spdx-correct'
fs = require 'fs'
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

checkMissing = (pack, fileName, {quiet}) ->
  required = config.required
  warnItems = (
    if pack.private
      config.warnOnPrivate
    else
      config.warn
  )

  for key in required
    if not pack[key]
      throw new Error("#{fileName} missing required key: #{key}")

  for key in warnItems
    if not pack[key] and not quiet
      console.log "#{fileName} missing: #{key}"

fixLicense = (pack, file, {quiet}) ->
  if pack.licenses?
    console.warn "#{file}: invalid key 'licenses' found, not fixing"

  if not pack.license?
    for key, value of pack
      if key.toLowerCase() in LICENSE_MISPELLINGS
        console.warn "#{file}: mispelled key '#{key}' found, corrected to
        'license'"
        pack.license = value
        delete pack[key]
        break

  if pack.license? and pack.license isnt 'UNLICENSED' and
     not spdx.valid(pack.license)
    corrected = correctLicense(pack.license)
    console.warn "#{file}: invalid SPDX license expression '#{pack.license}',
    corrected to '#{corrected}'"
    pack.license = corrected

  if not pack.license?
    console.warn "#{file}: license field missing - defaulting to 'UNLICENSED'
    (disallows others from using this module)"
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

module.exports = (file, {quiet}) ->
  try
    original = fs.readFileSync(file, encoding: 'utf8')
  catch err
    if err.code is 'ENOENT'
      console.error "ENOENT: no such file '#{file}'"
      process.exit 1
    else
      throw err

  pack = ALCE.parse(original)
  out = {}
  outputString = ''

  # make sure we have everything
  checkMissing pack, file, {quiet}
  fixLicense(pack, file, {quiet})

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

  # write it out
  outputString = JSON.stringify(out, null, 2) + '\n'
  if outputString isnt original
    fs.writeFileSync file, outputString, encoding: 'utf8'
    if not quiet then console.log "#{file}: fixed"
  else
    if not quiet then console.log "#{file}: already clean"
