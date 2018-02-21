# FormatParser

[![Build Status](https://travis-ci.org/ahtung/format_parser.ex.svg?branch=master)](https://travis-ci.org/ahtung/format_parser.ex)
[![Coverage Status](https://coveralls.io/repos/ahtung/format_parser.ex/badge.svg?branch=master)](https://coveralls.io/r/ahtung/format_parser.ex?branch=master)
[![Hex.pm version](https://img.shields.io/hexpm/v/format_parser.svg?style=flat-square)](https://hex.pm/packages/format_parser)
[![Hex.pm downloads](https://img.shields.io/hexpm/dt/format_parser.svg)](https://hex.pm/packages/format_parser)

FormatParser can be used to figure out the file type and format of a file as well as extracting some extra information about the file.

Documentation can be found [here](https://hexdocs.pm/format_parser).

Inspired heavily by [format_parser](https://github.com/WeTransfer/format_parser/).

## Basic usage

```elixir
# Image
{:ok, file} = File.read("myimage.gif")
match = FormatParser.parse(file)
match.nature              #=> :image
match.format              #=> :gif
match.width_px            #=> 256
match.height_px           #=> 256

# Video
{:ok, file} = File.read("myvideo.flv")
match = FormatParser.parse(file)
match.nature              #=> :video
match.format              #=> :flv

# Document
{:ok, file} = File.read("mydocument.rtf")
match = FormatParser.parse(file)
match.nature              #=> :document
match.format              #=> :rtf

# Audio
{:ok, file} = File.read("myaudio.wav")
match = FormatParser.parse(file)
match.nature              #=> :audio
match.format              #=> :wav
match.sample_rate_hz      #=> 44100
match.num_audio_channels  #=> 2

# Font
{:ok, file} = File.read("myfont.ttf")
match = FormatParser.parse(file)
match.nature              #=> :font
match.format              #=> :ttf

```

## Supported Formats

### Audio

| Type  | Nature | Format | Sample Rate | # of Channels |
| :---: | :----: | :----: | :---------: | :-----------: |
| aiff  | x      | x      |             |               |
| wav   | x      | x      | x           | x             |
| ogg   | x      | x      |             |               |
| flac  | x      | x      |             |               |

### Video

| Type | Nature | Format |
| :--: | :----: | :----: |
| flv  | x      | x      |

### Document

| Type | Nature | Format |
| :--: | :----: | :----: |
| rtf  | x      | x      |

### Image

| Type | Nature | Format | Width | Height |
| :--: | :----: | :----: | :---: | :----: |
| jpg  | x      | x      |       |        |
| gif  | x      | x      | x     | x      |
| ico  | x      | x      | x     | x      |
| cur  | x      | x      | x     | x      |
| cr2  | x      | x      | x     | x      |
| nef  | x      | x      | x     | x      |
| tif  | x      | x      | x     | x      |
| bmp  | x      | x      | x     | x      |
| png  | x      | x      | x     | x      |
| psd  | x      | x      | x     | x      |
| jb2  | x      | x      |       |        |
| xcf  | x      | x      |       |        |
| exr  | x      | x      |       |        |

### Font

| Type | Nature | Format |
| :--: | :----: | :----: |
| ttf  | x      | x      |
| otf  | x      | x      |
| fon  | x      | x      |

## Installation

```elixir
def deps do
  [
    {:format_parser, "~> 0.9.0"}
  ]
end
```

## Roadmap

(-) Parse width/height from `jpeg`, `exr`, `xcf` & `jb2`
(-) Implement intrinsics for all
(-) Split up Image, Audio, Video, Font & Document parsers to their own module
(-) Get Sample Rate and # Of Channels from `aiff`, `ogg` & `flac`
(-) Add support for big-endian tiff

## Contribute

Please feel free to fork and send us a PR or open up an issue.
