# FormatParser

**TODO: Add description**

## Basic usage

```elixir
{:ok, file} = File.read("myimage.jpg")
match = FormatParser.parse(file)
match.nature        #=> :image
match.format        #=> :jpg
match.width_px      #=> 320
match.height_px     #=> 240
match.orientation   #=> :top_left
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
