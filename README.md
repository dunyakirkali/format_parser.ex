# FormatParser

[![Build Status](https://travis-ci.org/ahtung/format_parser.ex.svg?branch=master)](https://travis-ci.org/ahtung/format_parser.ex)
[![Coverage Status](https://coveralls.io/repos/ahtung/format_parser.ex/badge.svg?branch=master)](https://coveralls.io/r/ahtung/format_parser.ex?branch=master)
[![Hex.pm version](https://img.shields.io/hexpm/v/format_parser.svg?style=flat-square)](https://hex.pm/packages/format_parser)
[![Hex.pm downloads](https://img.shields.io/hexpm/dt/format_parser.svg)](https://hex.pm/packages/format_parser)

Can be used to figure out the file type and format.

Inspired heavily by [format_parser](https://github.com/WeTransfer/format_parser/).

## Basic usage

```elixir
# Image
{:ok, file} = File.read("myimage.jpg")
match = FormatParser.parse(file)
match.nature        #=> :image
match.format        #=> :jpg

# Video
{:ok, file} = File.read("myvideo.flv")
match = FormatParser.parse(file)
match.nature        #=> :video
match.format        #=> :flv

# Document
{:ok, file} = File.read("mydocument.rtf")
match = FormatParser.parse(file)
match.nature        #=> :document
match.format        #=> :rtf

# Audio
{:ok, file} = File.read("myaudio.wav")
match = FormatParser.parse(file)
match.nature        #=> :audio
match.format        #=> :wav

# Font
{:ok, file} = File.read("myfont.ttf")
match = FormatParser.parse(file)
match.nature        #=> :font
match.format        #=> :ttf

```

## Supported Formats

### Audio

- aiff
- wav
- ogg
- flac

### Video

- flv

### Document

- rtf

### Image

- jpg
- gif
- cr2
- ico
- tif
- bmp
- png

### Font

- ttf
- otf

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
