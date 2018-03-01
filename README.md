# FormatParser

[![Build Status](https://travis-ci.org/ahtung/format_parser.ex.svg?branch=master)](https://travis-ci.org/ahtung/format_parser.ex)
[![Coverage Status](https://coveralls.io/repos/ahtung/format_parser.ex/badge.svg?branch=master)](https://coveralls.io/r/ahtung/format_parser.ex?branch=master)
[![Hex.pm version](https://img.shields.io/hexpm/v/format_parser.svg?style=flat-square)](https://hex.pm/packages/format_parser)
[![Hex.pm downloads](https://img.shields.io/hexpm/dt/format_parser.svg)](https://hex.pm/packages/format_parser)

FormatParser can be used to figure out the type and the format of a file.
It also can extract some additional information.

Documentation can be found [here](https://hexdocs.pm/format_parser).

Inspired heavily by [format_parser](https://github.com/WeTransfer/format_parser/).

## Basic usage

```elixir
# Image
{:ok, file} = File.read("myimage.png")
match = FormatParser.parse(file)
match.nature                      #=> :image
match.format                      #=> :gif
match.width_px                    #=> 256
match.height_px                   #=> 256
match.intrinsics[:filter_method]  #=> 0

# Video
{:ok, file} = File.read("myvideo.flv")
match = FormatParser.parse(file)
match.nature                      #=> :video
match.format                      #=> :flv

# Document
{:ok, file} = File.read("mydocument.rtf")
match = FormatParser.parse(file)
match.nature                      #=> :document
match.format                      #=> :rtf

# Audio
{:ok, file} = File.read("myaudio.wav")
match = FormatParser.parse(file)
match.nature                      #=> :audio
match.format                      #=> :wav
match.sample_rate_hz              #=> 44100
match.num_audio_channels          #=> 2

# Font
{:ok, file} = File.read("myfont.ttf")
match = FormatParser.parse(file)
match.nature                      #=> :font
match.format                      #=> :ttf

```

## Supported Formats

### Audio

| Type  | Nature | Format | Sample Rate | # of Channels | Intrinsics                              |
| :---: | :----: | :----: | :---------: | :-----------: | :-------------------------------------- |
| aiff  | x      | x      |             | x             | num_frames, bits_per_sample             |
| wav   | x      | x      | x           | x             | byte_rate, block_align, bits_per_sample |
| ogg   | x      | x      | x           | x             |                                         |
| flac  | x      | x      | x           | x             |                                         |

### Video

| Type | Nature | Format |
| :--: | :----: | :----: |
| flv  | x      | x      |

### Document

| Type | Nature | Format |
| :--: | :----: | :----: |
| rtf  | x      | x      |

### Image

| Type | Nature | Format | Width | Height | Intrinsics                                                                      |
| :--: | :----: | :----: | :---: | :----: | :------------------------------------------------------------------------------ |
| jpg  | x      | x      |       |        |                                                                                 |
| gif  | x      | x      | x     | x      |                                                                                 |
| ico  | x      | x      | x     | x      | num_color_palette, color_planes, bits_per_pixel                                 |
| cur  | x      | x      | x     | x      | num_color_palette, hotspot_horizontal_coords, hotspot_vertical_coords           |
| cr2  | x      | x      | x     | x      |                                                                                 |
| nef  | x      | x      | x     | x      |                                                                                 |
| tif  | x      | x      | x     | x      |                                                                                 |
| bmp  | x      | x      | x     | x      |                                                                                 |
| png  | x      | x      | x     | x      | bit_depth, color_type, compression_method, crc, filter_method, interlace_method |
| psd  | x      | x      | x     | x      |                                                                                 |
| jb2  | x      | x      |       |        |                                                                                 |
| xcf  | x      | x      |       |        |                                                                                 |
| exr  | x      | x      |       |        |                                                                                 |

### Font

| Type | Nature | Format |
| :--: | :----: | :----: |
| ttf  | x      | x      |
| otf  | x      | x      |
| fon  | x      | x      |

## Installation

Add the following to your `mix.exs` file

```elixir
def deps do
  [
    {:format_parser, "~> 1.1.0"}
  ]
end
```

And run `mix deps.get`

## Contribute

Please feel free to fork and send us a PR or open up an issue.
