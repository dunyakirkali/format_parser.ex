defmodule FormatParser.Document do
  alias __MODULE__

  @moduledoc """
  A Document struct and functions.

  The Document struct contains the fields format and nature.
  """

  defstruct [:format, nature: :document]

  @doc """
  Parses a file and extracts some information from it.

  Takes a `binary file` as argument.

  Returns a struct which contains all information that has been extracted from the file if the file is recognized.

  Returns the following tuple if file not recognized: `{:error, file}`.

  """
  def parse({:error, file}) when is_binary(file) do
    parse_document(file)
  end

  def parse(file) when is_binary(file) do
    parse_document(file)
  end

  def parse(result) do
    result
  end

  defp parse_document(file) do
    case file do
      <<0x7B, 0x5C, 0x72, 0x74, 0x66, 0x31, x :: binary>> -> parse_rtf(x)
      <<"%PDF", x :: binary>> -> parse_pdf(x)
      _ -> {:error, file}
    end
  end

  defp parse_rtf(<<_x :: binary>>) do
    %Document{format: :rtf}
  end

  defp parse_pdf(<<_x :: binary>>) do
    %Document{format: :pdf}
  end
end
