defmodule FormatParser do
  alias FormatParser.{Archive, Audio, Data, Document, Font, Image, Video}

  @moduledoc """
  FormatParser - A file format detection library for Elixir.

  FormatParser parses binary file data and extracts the format and additional metadata from it.
  It supports a wide variety of file types across multiple categories.

  ## Supported Categories

    * **Images** - PNG, JPEG, GIF, BMP, TIFF, PSD, WebP, HEIC, HEIF, AVIF, JXL, SVG, ICO, and RAW formats (CR2, NEF)
    * **Audio** - WAV, MP3, FLAC, AAC, M4A, Vorbis, Opus, AIFF, MIDI
    * **Video** - MP4, AVI, MKV, WebM, MOV, WMV, FLV
    * **Documents** - PDF, RTF, DOCX, XLSX, PPTX, ODT, ODS, ODP, EPUB
    * **Fonts** - TTF, OTF, WOFF, WOFF2, FON
    * **Archives** - ZIP, RAR, 7z, GZIP, BZIP2, XZ, TAR, ISO, ZSTD
    * **Data** - Parquet, SQLite, DuckDB, Arrow, Feather

  ## Basic Usage

      {:ok, file} = File.read("image.png")
      result = FormatParser.parse(file)
      result.nature   #=> :image
      result.format   #=> :png
      result.width_px #=> 800

  ## Return Types

  The `parse/1` function returns a struct specific to the detected file type:

    * `%FormatParser.Image{}` - For image files
    * `%FormatParser.Audio{}` - For audio files
    * `%FormatParser.Video{}` - For video files
    * `%FormatParser.Document{}` - For document files
    * `%FormatParser.Font{}` - For font files
    * `%FormatParser.Archive{}` - For archive files
    * `%FormatParser.Data{}` - For data files
    * `{:error, "Unknown"}` - When the format is not recognized

  """

  @parsers [Font, Audio, Document, Video, Image, Data, Archive]

  @doc """
  Parses a file and extracts some information from it.

  Takes a `binary file` as argument.

  Returns a struct which contains all information that has been extracted from the file if the file is recognized.

  Returns the following tuple if file not recognized: `{:error, "Unknown"}`.

  ## Examples

      iex> {:ok, file} = File.read("priv/test.jpg")
      iex> FormatParser.parse(file)
      %FormatParser.Image{format: :jpg, height_px: 234, nature: :image, width_px: 313}

      iex> {:ok, file} = File.read("priv/test.html")
      iex> FormatParser.parse(file)
      {:error, "Unknown"}

  """
  @spec parse(binary) :: struct | {:error, String.t()}
  def parse(file) when is_binary(file) do
    @parsers
    |> Enum.reduce_while({:error, file}, fn parser, {:error, f} ->
      case parser.parse(f) do
        {:error, _} = error -> {:cont, error}
        result -> {:halt, result}
      end
    end)
    |> case do
      {:error, _} -> {:error, "Unknown"}
      result -> result
    end
  end
end
