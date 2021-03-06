# fixpack

[![Build Status](http://img.shields.io/travis/slang800/fixpack.svg?style=flat-square)](https://travis-ci.org/slang800/fixpack) [![NPM version](http://img.shields.io/npm/v/fixpack.svg?style=flat-square)](https://www.npmjs.org/package/fixpack) [![NPM license](http://img.shields.io/npm/l/fixpack.svg?style=flat-square)](https://www.npmjs.org/package/fixpack)

A package.json file scrubber for the truly insane.

It will re-write your package.json file as follows:

- `name` first
- `description` second
- `version` third
- `author` fourth
- all other keys in alphabetical order
- `dependencies` and `devDependencies` sorted alphabetically
- newline at the end of the file

It will warn you if any of these are missing:

- `description`
- `author`
- `repository`
- `keywords`
- `main`
- `bugs`
- `homepage`
- `license`

Fix all indenting to 2 spaces.

Oh, and it will tolerate improperly quoted and comma'd JSON thanks to [ALCE](https://npmjs.org/package/alce).

Oh, and you can do the same thing if you pass it a `bower.json` file or whatnot.

## Usage

1. install it globally

  ```bash
  npm install --global fixpack
  ```

2. run it in the same directory as your package.json, that's it.

  ```bash
  fixpack
  ```

## What you might do if you're clever

```bash
npm install cool-package --save && fixpack
```

## Changelog

- 2.0.1 - don't error on missing bower file by default.
- 2.0.0 - configurable via `.fixpackrc` file using rc module.
- x.x.x - unknown miscellaneous madness and poor version tracking
- 0.0.2 [diff](https://github.com/HenrikJoreteg/fixpack/compare/v0.0.1...v0.0.2) - EOF newline
- 0.0.1 - initial release

## Credits

This embarrassing display of insanity, type-A-ness, and OCD brought to you by [@HenrikJoreteg](http://twitter.com/henrikjoreteg).
