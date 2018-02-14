# FormatParser

[![Build Status](https://travis-ci.org/ahtung/format_parser.ex.svg?branch=master)](https://travis-ci.org/ahtung/format_parser.ex)
[![Coverage Status](https://coveralls.io/repos/ahtung/format_parser.ex/badge.svg?branch=master)](https://coveralls.io/r/ahtung/format_parser.ex?branch=master)
[![Hex.pm version](https://img.shields.io/hexpm/v/format_parser.svg?style=flat-square)](https://hex.pm/packages/format_parser)
[![Hex.pm downloads](https://img.shields.io/hexpm/dt/format_parser.svg)](https://hex.pm/packages/format_parser)

**TODO: Add description**

## Basic usage

```elixir
{:ok, file} = File.read("myimage.jpg")
match = FormatParser.parse(file)
match.nature        #=> :image
match.format        #=> :jpg
match.width_px      #=> 320
match.height_px     #=> 240
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `format_parser` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:format_parser, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/format_parser](https://hexdocs.pm/format_parser).
