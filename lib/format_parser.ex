defmodule FormatParser do
  alias FormatParser.{Archive, Audio, Data, Document, Font, Image, Video}

  @moduledoc """
  The FormatParser Module

  FormatParser parses a binary file and extracts the format and some additional information from it.
  It can deal with Audio, Video, Fonts, Images, Archives and Documents.

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
