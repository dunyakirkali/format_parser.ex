defmodule FormatParser.Font do
  alias __MODULE__

  @moduledoc """
  A Font struct and functions.

  The Font struct contains the fields format and nature.
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
  - For any other input, returns the input as-is.

  ## Examples

    iex> parse({:error, "font.ttf"})
    # Parses the font from "font.ttf"

    iex> parse("font.ttf")
    # Parses the font from "font.ttf"

    iex> parse(:ok)
    :ok

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
