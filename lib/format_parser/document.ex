defmodule FormatParser.Document do
  alias __MODULE__

  @moduledoc """
  A Document struct and functions.

  The Document struct contains the fields format and nature.
  """

  defstruct [:format, nature: :document, intrinsics: %{}]

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
      <<0x7B, 0x5C, 0x72, 0x74, 0x66, 0x31, x::binary>> -> parse_rtf(x)
      <<"%PDF", x::binary>> -> parse_pdf(x)
      <<"PK", 0x03, 0x04, rest::binary>> -> parse_zip_file(rest, file)
      <<0xD0, 0xCF, 0x11, 0xE0, _::binary>> -> parse_doc(file)
      _ -> {:error, file}
    end
  end

  @doc """
  Parses an RTF file and returns a Document struct with format set to :rtf.
  """
  defp parse_rtf(<<_x::binary>>) do
    %Document{format: :rtf}
  end

  @doc """
  Parses a PDF file and returns a Document struct with format set to :pdf.
  Extracts the page count from the file if available.
  """
  defp parse_pdf(<<x::binary>>) do
    page_count =
      case Regex.run(~r/<<\/Linearized.+\/N\s([0-9]+)/, x) do
        nil -> 0
        match -> match |> List.last() |> String.to_integer()
      end

    %Document{format: :pdf, intrinsics: %{page_count: page_count}}
  end

  @doc """
  Parses a DOCX file and returns a Document struct with format set to :docx.
  """
  defp parse_docx(<<_::binary>>) do
    %Document{format: :docx}
  end

  @doc """
  Parses a DOC file and returns a Document struct with format set to :doc.
  """
  defp parse_doc(<<_::binary>>) do
    %Document{format: :doc}
  end

  @doc """
  Parses an ODT file and returns a Document struct with format set to :odt.
  """
  defp parse_odt(<<_::binary>>) do
    %Document{format: :odt}
  end

  @doc """
  Determines if a ZIP file is a DOCX or ODT file based on its contents.
  """
  defp parse_zip_file(<<_::binary-size(300), "word/", _::binary>>, file), do: parse_docx(file)
  defp parse_zip_file(_, file), do: parse_odt(file)
end
