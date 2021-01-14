defmodule FormatParser.Font do
  alias __MODULE__

  @moduledoc """
  A Font struct and functions.

  The Font struct contains the fields format and nature.
  """

  defstruct [:format, nature: :font]

  @doc """
  Parses a file and extracts some information from it.

  Takes a `binary file` as argument.

  Returns a struct which contains all information that has been extracted from the file if the file is recognized.

  Returns the following tuple if file not recognized: `{:error, file}`.

  """
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
end
