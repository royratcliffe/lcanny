# lcanny

[![codecov](https://codecov.io/gh/royratcliffe/lcanny/branch/master/graph/badge.svg)](https://codecov.io/gh/royratcliffe/lcanny)

A collection of Lua utility modules for table operations, iteration,
serialisation, and string building.

## Modules

- `by`: group values by a key function.
- `collecting`: collect iterator values or key-value pairs into tables.
- `indexing`: access values and create nested indices with defaults.
- `interleaving`: iterate arrays as pairs of values.
- `is`: check Lua identifiers and array tables.
- `patching`: diff tables and apply patches in place.
- `recursing`: iterate table leaves and branches, or look up nested values.
- `serialising`: serialise Lua values and tables as Lua source.
- `strbuf`: build strings using a callable buffer.

Each module is required by its name, for example `require("collecting")`.

## Requirements

- Lua 5.1 or newer
- [LuaRocks](https://luarocks.org/)

## Build and install locally

From the project root, run:

```sh
luarocks make lcanny-0.1.0-1.rockspec
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
rockspec, commit and push the matching `v0.1.0` Git tag, and verify the package
with `luarocks lint lcanny-0.1.0-1.rockspec`.
