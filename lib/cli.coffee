ArgumentParser = require('argparse').ArgumentParser
fs = require 'fs'

fixpack = require './'
packageInfo = require '../package'

argparser = new ArgumentParser(
  addHelp: true
  description: packageInfo.description
  version: packageInfo.version
)

argparser.addArgument(
  []
  defaultValue: ['./package.json']
  dest: 'files'
  help: 'The package.json file(s) to fix. Defaults to ./package.json.'
  metavar: 'FILE'
  nargs: '*'
  type: 'string'
)

argparser.addArgument(
  ['-q', '--quiet']
  action: 'storeTrue'
  defaultValue: false
  help: 'Don\'t output any log messages.'
)

argv = argparser.parseArgs()

for file in argv.files
  try
    originalContent = fs.readFileSync(file, encoding: 'utf8')
  catch err
    if err.code is 'ENOENT'
      console.error "ENOENT: no such file '#{file}'"
      process.exit 1
    else
      throw err

  log = (
    if argv.quiet
      -> # noop
    else
      (message) -> console.log "#{file}: #{message}"
  )

  outputString = fixpack originalContent, {log}
  if outputString isnt originalContent
    fs.writeFileSync file, outputString, encoding: 'utf8'
    log 'fixed'
  else
    log 'already clean'
