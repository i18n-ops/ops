#!/usr/bin/env coffee

> zx/globals:

ROOT = import.meta.dirname

< default main = =>
  cd ROOT
  await $"ls #{ROOT}"
  await $'pwd'
  return

if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
  await main()
  process.exit()
