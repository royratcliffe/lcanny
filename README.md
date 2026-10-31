# lcanny

[![codecov](https://codecov.io/gh/royratcliffe/lcanny/branch/master/graph/badge.svg)](https://codecov.io/gh/royratcliffe/lcanny)

A collection of Lua utility modules for table operations, iteration,
serialisation, and string building.

## Modules

- `by`: group values by a key function.
- `co`: run coroutine lists with configurable error logging.
- `collecting`: collect iterator values or key-value pairs into tables.
- `div`: calculate quotients and modulo values.
- `filename`: read and write files with automatic closure.
- `filtering`: collect pairs that satisfy a filter.
- `hi`: build half-duplex calling functions.
- `indexing`: access values and create nested indices with defaults.
- `interleaving`: iterate arrays as pairs of values.
- `is`: check Lua identifiers and array tables.
- `leap`: perform proleptic Gregorian calendar and leap-year calculations.
- `patching`: diff tables and apply patches in place.
- `recursing`: iterate table leaves and branches, or look up nested values.
- `redis`: connect to Redis using RESP version 2.
- `resp`: send and receive RESP version-2 messages and iterate Redis results.
- `serialising`: serialise Lua values and tables as Lua source.
- `so`: wrap socket operations with timeout callbacks.
- `strbuf`: build strings using a callable buffer.
- `uu`: generate time-, random-, and sequence-based identifiers.

Each module is required by its name, for example `require("collecting")`.

### Coroutine error logging

The `co` module reports coroutine errors through `co.log(message)`, which
writes to stderr by default. Replace the callback to use an application logger:

```lua
local co = require "co"
co.log = function(message)
  log.write("on", log.ERROR, message)
end
```

The callback receives a string and applies to all coroutine lists, including
existing ones. Logger failures propagate to the caller.

## Requirements

- Lua 5.1 or newer
- [LuaRocks](https://luarocks.org/)
- [LuaSocket](https://lunarmodules.github.io/luasocket/) (installed by LuaRocks)

Loading `redis` opens a connection to `REDISCLI_HOST` (default: `localhost`)
on port 6379 and requires a running Redis server.

## Build and install locally

From the project root, run:

```sh
luarocks make lcanny-0.2.0-1.rockspec
```

## Run the Busted specs

Install Busted with `luarocks install busted`, then run the specs from the
project root:

```sh
busted
```

To collect a LuaCov coverage report, install LuaCov with
`luarocks install luacov` and run:

```sh
busted --coverage
luacov
```

The coverage workflow runs this on Lua 5.1 and 5.4 for pushes and pull requests.
Codecov excludes the `spec/` directory from coverage metrics.

### Coverage in VS Code on Windows

Install the recommended **Coverage Gutters** extension and the LCOV reporter:

```sh
luarocks install --local luacov-reporter-lcov
```

Run **Tasks: Run Task** from the Command Palette and select **Busted coverage**.
The task configures the LuaRocks environment, clears previous coverage data,
runs all specs, and writes source coverage to `lcov.info`.

Then run **Coverage Gutters: Watch** from the Command Palette to display
covered and uncovered lines in the editor gutter. Rerun the task after changes;
the extension refreshes automatically. Generated coverage files are ignored
by Git.

## Generate API documentation

Install LDoc with `luarocks install ldoc`, then generate HTML documentation:

```sh
ldoc --fatalwarnings --testing -c config.ld src
```

The generated site is written to `doc`.

## Publishing

Before uploading a release, update the repository URL and homepage in the
rockspec, commit and push the matching `v0.2.0` Git tag, and verify the package
with `luarocks lint lcanny-0.2.0-1.rockspec`.
