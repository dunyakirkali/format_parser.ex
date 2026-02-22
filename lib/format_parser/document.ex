defmodule FormatParser.Document do
  alias __MODULE__

  @moduledoc """
  A Document struct and functions.

  The Document struct contains the fields format, nature, and intrinsics.

  ## Supported Formats

  | Format | Extension | Description |
  |--------|-----------|-------------|
  | `:rtf` | .rtf | Rich Text Format |
  | `:pdf` | .pdf | Portable Document Format |
  | `:docx` | .docx | Microsoft Word (Open XML) |
  | `:doc` | .doc | Microsoft Word (Legacy) |
  | `:xlsx` | .xlsx | Microsoft Excel (Open XML) |
  | `:pptx` | .pptx | Microsoft PowerPoint (Open XML) |
  | `:odt` | .odt | OpenDocument Text |
  | `:ods` | .ods | OpenDocument Spreadsheet |
  | `:odp` | .odp | OpenDocument Presentation |
  | `:epub` | .epub | Electronic Publication |

  ## Intrinsics

  Some formats provide additional metadata in the `intrinsics` field:

  - PDF: `%{page_count: integer}` - Number of pages (from linearized PDFs)

  """

  @typedoc """
  A struct representing a parsed document file.

  ## Fields

    * `:format` - The document format as an atom (e.g., `:pdf`, `:docx`, `:odt`)
    * `:nature` - Always `:document` for document files
    * `:intrinsics` - A map containing format-specific metadata

  """
  @type t :: %__MODULE__{
          format: atom() | nil,
          nature: :document,
          intrinsics: map()
        }
  defstruct [:format, nature: :document, intrinsics: %{}]

  @doc """
  Parses a document from the given input.

  This function attempts to identify document formats by examining magic bytes
  and internal file structure. ZIP-based formats (DOCX, XLSX, PPTX, ODT, ODS, ODP, EPUB)
  are detected by examining their internal file entries.

  ## Arguments

    * `input` - Can be one of:
      * `{:error, binary}` - A tuple containing binary file content (used in parser chain)
      * `binary` - Raw binary file content
      * `any` - Any other value is returned as-is (pass-through for parser chain)

  ## Returns

    * `%FormatParser.Document{}` - When a supported document format is detected
    * `{:error, binary}` - When the format is not recognized (for parser chain)
    * The input unchanged - When input is neither a binary nor an error tuple

  ## Examples

      iex> {:ok, file} = File.read("priv/test.pdf")
      iex> result = FormatParser.Document.parse(file)
      iex> result.format
      :pdf

      iex> FormatParser.Document.parse(%FormatParser.Image{})
      %FormatParser.Image{}

  """
  @spec parse({:error, binary()} | binary() | any()) :: any()
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
      <<"PK", 0x03, 0x04, _rest::binary>> -> parse_zip_based_format(file)
      <<0xD0, 0xCF, 0x11, 0xE0, _::binary>> -> parse_doc(file)
      _ -> {:error, file}
    end
  end

  defp parse_rtf(<<_x::binary>>) do
    %Document{format: :rtf}
  end

  defp parse_pdf(<<x::binary>>) do
    page_count =
      case Regex.run(~r/<<\/Linearized.+\/N\s([0-9]+)/, x) do
        nil -> 0
        match -> match |> List.last() |> String.to_integer()
      end

    %Document{format: :pdf, intrinsics: %{page_count: page_count}}
  end

  defp parse_doc(<<_::binary>>) do
    %Document{format: :doc}
  end

  # ZIP-based format detection
  # Searches for characteristic filenames within the ZIP archive
  defp parse_zip_based_format(file) do
    cond do
      # EPUB format - check mimetype content
      is_epub?(file) ->
        %Document{format: :epub}

      # Microsoft Office Open XML formats
      contains_zip_entry?(file, "word/") ->
        %Document{format: :docx}

      contains_zip_entry?(file, "xl/") ->
        %Document{format: :xlsx}

      contains_zip_entry?(file, "ppt/") ->
        %Document{format: :pptx}

      # OpenDocument formats - check mimetype content
      is_odt?(file) ->
        %Document{format: :odt}

      is_ods?(file) ->
        %Document{format: :ods}

      is_odp?(file) ->
        %Document{format: :odp}

      # Generic OpenDocument (has mimetype but we couldn't identify specific type)
      contains_zip_entry?(file, "mimetype") and contains_zip_entry?(file, "content.xml") ->
        %Document{format: :odf}

      # Not a document format - let other parsers handle it
      true ->
        {:error, file}
    end
  end

  # Check if the ZIP file contains a specific entry/path
  # This searches for the filename in the ZIP central directory or local file headers
  defp contains_zip_entry?(file, entry_name) do
    String.contains?(file, entry_name)
  end

  # OpenDocument Text - mimetype contains "application/vnd.oasis.opendocument.text"
  defp is_odt?(file) do
    contains_zip_entry?(file, "mimetype") and
      String.contains?(file, "application/vnd.oasis.opendocument.text")
  end

  # OpenDocument Spreadsheet - mimetype contains "application/vnd.oasis.opendocument.spreadsheet"
  defp is_ods?(file) do
    contains_zip_entry?(file, "mimetype") and
      String.contains?(file, "application/vnd.oasis.opendocument.spreadsheet")
  end

  # OpenDocument Presentation - mimetype contains "application/vnd.oasis.opendocument.presentation"
  defp is_odp?(file) do
    contains_zip_entry?(file, "mimetype") and
      String.contains?(file, "application/vnd.oasis.opendocument.presentation")
  end

  # EPUB - mimetype contains "application/epub+zip"
  defp is_epub?(file) do
    contains_zip_entry?(file, "mimetype") and
      String.contains?(file, "application/epub+zip")
  end
end
