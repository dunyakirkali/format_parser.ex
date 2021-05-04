defmodule FormatParser do
  alias FormatParser.{Audio, Document, Font, Image, Video}

  @moduledoc """
  The FormatParser Module

  FormatParser parses a binary file and extracts the format and some additional information from it.
  It can deal with Audio, Video, Fonts, Images and Documents.

  """

  @doc """
  Parses a file and extracts some information from it.

  Takes a `binary file` as argument.

  Returns a struct which contains all information that has been extracted from the file if the file is recognized.

  Returns the following tuple if file not recognized: `{:error, "Unknown"}`.

  ## Examples

      iex> {:ok, file} = File.read("priv/test.jpg")
      iex> FormatParser.parse(file)
      %FormatParser.Image{format: :jpg, height_px: nil, nature: :image, width_px: nil}

      iex> {:ok, file} = File.read("priv/test.html")
      iex> FormatParser.parse(file)
      {:error, "Unknown"}

  """
  @spec parse(binary) :: struct
  def parse(file) when is_binary(file) do
    file
    |> Font.parse()
    |> Audio.parse()
    |> Document.parse()
    |> Video.parse()
    |> Image.parse()
    |> case do
      {:error, _} -> {:error, "Unknown"}
      result -> result
    end
  end
end
