# FormatParser

![Code Quality](https://github.com/ahtung/format_parser.ex/workflows/Code%20Quality/badge.svg)
![Continuous Integration](https://github.com/ahtung/format_parser.ex/workflows/Continuous%20Integration/badge.svg)
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

# Data
{:ok, file} = File.read("mydata.parquet")
match = FormatParser.parse(file)
match.nature                      #=> :data
match.format                      #=> :pqt

# Archive
{:ok, file} = File.read("myarchive.iso")
match = FormatParser.parse(file)
match.nature                      #=> :archive
match.format                      #=> :iso

```

## Supported Formats

### Data

| Type     | Nature | Format | Intrinsics |
| :------: | :----: | :----: | :--------- |
| pqt      | x      | x      |            |
| sqlite3  | x      | x      |            |
| duckdb   | x      | x      |            |
| arrow    | x      | x      |            |
| feather  | x      | x      |            |

### Audio

| Type   | Nature | Format | Sample Rate | # of Channels | Intrinsics                                     |
| :----: | :----: | :----: | :---------: | :-----------: | :--------------------------------------------: |
| aiff   | x      | x      |             | x             | num_frames, bits_per_sample                    |
| wav    | x      | x      | x           | x             | byte_rate, block_align, bits_per_sample        |
| vorbis | x      | x      | x           | x             | vorbis_version                                 |
| opus   | x      | x      | x           | x             | version, pre_skip, output_gain, mapping_family |
| flac   | x      | x      | x           | x             |                                                |
| aac    | x      | x      | x           | x             |                                                |
| midi   | x      | x      |             |               | format, num_tracks, time_division              |

### Video

| Type | Nature | Format |
| :--: | :----: | :----: |
| flv  | x      | x      |
| mp4  | x      | x      |
| avi  | x      | x      |
| wmv  | x      | x      |
| mov  | x      | x      |
| webm | x      | x      |
| mkv  | x      | x      |

### Document

| Type | Nature | Format | Intrinsics |
| :--: | :----: | :----: | :--------- |
| rtf  | x      | x      |            |
| pdf  | x      | x      | page_count |
| docx | x      | x      |            |
| doc  | x      | x      |            |
| xlsx | x      | x      |            |
| pptx | x      | x      |            |
| odt  | x      | x      |            |
| ods  | x      | x      |            |
| odp  | x      | x      |            |
| epub | x      | x      |            |

### Image

| Type | Nature | Format | Width | Height | Intrinsics                                                                      |
| :--: | :----: | :----: | :---: | :----: | :------------------------------------------------------------------------------ |
| jpg  | x      | x      |       |        |                                                                                 |
| gif  | x      | x      | x     | x      |                                                                                 |
| ico  | x      | x      | x     | x      | num_color_palette, color_planes, bits_per_pixel                                 |
| cur  | x      | x      | x     | x      | num_color_palette, hotspot_horizontal_coords, hotspot_vertical_coords           |
| cr2  | x      | x      | x     | x      | date_time, model, preview_byte_count, preview_offset                            |
| nef  | x      | x      | x     | x      | date_time, model, preview_byte_count, preview_offset                            |
| tif  | x      | x      | x     | x      |                                                                                 |
| bmp  | x      | x      | x     | x      |                                                                                 |
| png  | x      | x      | x     | x      | bit_depth, color_type, compression_method, crc, filter_method, interlace_method |
| psd  | x      | x      | x     | x      |                                                                                 |
| jb2  | x      | x      |       |        |                                                                                 |
| xcf  | x      | x      |       |        |                                                                                 |
| exr  | x      | x      |       |        |                                                                                 |
| webp | x      | x      |       |        |                                                                                 |
| heic | x      | x      |       |        |                                                                                 |
| heif | x      | x      |       |        |                                                                                 |
| avif | x      | x      |       |        |                                                                                 |
| jxl  | x      | x      |       |        |                                                                                 |
| svg  | x      | x      |       |        |                                                                                 |

### Font

| Type  | Nature | Format |
| :---: | :----: | :----: |
| ttf   | x      | x      |
| otf   | x      | x      |
| fon   | x      | x      |
| woff  | x      | x      |
| woff2 | x      | x      |

### Archive

| Type | Nature | Format |
| :--: | :----: | :----: |
| zip  | x      | x      |
| rar  | x      | x      |
| 7z   | x      | x      |
| gz   | x      | x      |
| bz2  | x      | x      |
| xz   | x      | x      |
| tar  | x      | x      |
| iso  | x      | x      |
| zstd | x      | x      |

## Installation

Add the following to your `mix.exs` file

```elixir
def deps do
  [
    {:format_parser, "~> 2.6.0"}
  ]
end
```

And run `mix deps.get`

## Contribute

Please feel free to fork and send us a PR or open up an issue.
