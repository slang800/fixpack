ArgumentParser = require('argparse').ArgumentParser

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
  fixpack file, {quiet: argv.quiet}
