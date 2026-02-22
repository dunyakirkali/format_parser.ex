defmodule FormatParser.Font do
  alias __MODULE__

  @moduledoc """
  A Font struct and functions.

  The Font struct contains the fields format and nature.

  ## Supported Formats

  | Format | Extension | Description |
  |--------|-----------|-------------|
  | `:ttf` | .ttf | TrueType Font |
  | `:otf` | .otf | OpenType Font |
  | `:fon` | .fon | Windows bitmap font |
  | `:woff` | .woff | Web Open Font Format |
  | `:woff2` | .woff2 | Web Open Font Format 2 |

  ## Examples

      iex> {:ok, file} = File.read("priv/test.ttf")
      iex> FormatParser.parse(file)
      %FormatParser.Font{format: :ttf, nature: :font}

  """

  @typedoc """
  A struct representing a parsed font file.

  ## Fields

    * `:format` - The font format as an atom (e.g., `:ttf`, `:otf`, `:woff`), or `nil` if unknown
    * `:nature` - Always `:font` for font files

  """
  @type t :: %Font{
          format: atom() | nil,
          nature: :font
        }

  defstruct [:format, nature: :font]

  @doc """
  Parses a font file or result.

  - If given a tuple `{:error, file}` where `file` is a binary, attempts to parse the font from the file.
  - If given a binary `file`, attempts to parse the font from the file.
  - For any other input, returns the input as-is (passthrough for parser chain).

  ## Examples

      iex> {:ok, file} = File.read("priv/test.ttf")
      iex> FormatParser.Font.parse(file)
      %FormatParser.Font{format: :ttf, nature: :font}

      iex> FormatParser.Font.parse(%FormatParser.Image{})
      %FormatParser.Image{}

  """
  @spec parse({:error, binary()} | binary() | any()) :: any()
  def parse({:error, file}) when is_binary(file) do
    parse_font(file)
  end

  def parse(file) when is_binary(file) do
    parse_font(file)
  end

  def parse(result) do
    result
  end

  defp parse_font(file) do
    case file do
      <<0x4D, 0x5A, x::binary>> -> parse_fon(x)
      <<0x00, 0x01, 0x00, 0x00, 0x00, x::binary>> -> parse_ttf(x)
      <<"OTTO", 0x00, x::binary>> -> parse_otf(x)
      <<"wOFF", x::binary>> -> parse_woff(x)
      <<"wOF2", x::binary>> -> parse_woff2(x)
      _ -> {:error, file}
    end
  end

  defp parse_otf(<<_::binary>>) do
    %Font{format: :otf}
  end

  defp parse_ttf(<<_x::binary>>) do
    %Font{format: :ttf}
  end

  defp parse_fon(<<_::binary>>) do
    %Font{format: :fon}
  end

  defp parse_woff(<<_::binary>>) do
    %Font{format: :woff}
  end

  defp parse_woff2(<<_::binary>>) do
    %Font{format: :woff2}
  end
end
