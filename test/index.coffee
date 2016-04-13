fixpackRaw = require '../lib'
should = require 'should'

# fixpack without the trailing newline
fixpack = (text) -> fixpackRaw(text, log: ->).trimRight()

describe 'fixpack', ->
  it 'should sort dependencies', ->
    fixpack('''
      {
        "name": "fixpack",
        "version": "1.2.3",
        "dependencies": {
          "spdx-correct": "^1.0.2",
          "argparse": "^1.0.3",
          "spdx": "^0.4.1",
          "alce": "1.0.0"
        },
        "devDependencies": {
          "mocha": "^2.4.5",
          "coffee-script": "^1.10.0"
        },
        "license": "GPL-3.0"
      }
    ''').should.equal('''
      {
        "name": "fixpack",
        "version": "1.2.3",
        "dependencies": {
          "alce": "1.0.0",
          "argparse": "^1.0.3",
          "spdx": "^0.4.1",
          "spdx-correct": "^1.0.2"
        },
        "devDependencies": {
          "coffee-script": "^1.10.0",
          "mocha": "^2.4.5"
        },
        "license": "GPL-3.0"
      }
    ''')

  it 'should fix license field mispelling', ->
    fixpack('''
      {
        "name": "fixpack",
        "version": "1.2.3",
        "licence": "GPL-3.0"
      }
    ''').should.equal('''
      {
        "name": "fixpack",
        "version": "1.2.3",
        "license": "GPL-3.0"
      }
    ''')

  it 'should fix non-SPDX license codes', ->
    fixpack('''
      {
        "name": "fixpack",
        "version": "1.2.3",
        "licence": "GPLv3"
      }
    ''').should.equal('''
      {
        "name": "fixpack",
        "version": "1.2.3",
        "license": "GPL-3.0"
      }
    ''')

  it 'should fix version strings', ->
    fixpack('''
      {
        "name": "fixpack",
        "version": "  =v1.2.3   ",
        "licence": "GPLv3"
      }
    ''').should.equal('''
      {
        "name": "fixpack",
        "version": "1.2.3",
        "license": "GPL-3.0"
      }
    ''')
