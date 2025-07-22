defmodule FormatParser.Document do
  alias __MODULE__

  @moduledoc """
  A Document struct and functions.

  The Document struct contains the fields format and nature.
  """

  @type t :: %__MODULE__{
          format: any(),
          nature: atom(),
          intrinsics: map()
        }
  defstruct [:format, nature: :document, intrinsics: %{}]

  @doc """
  Parses a document from the given input.

  - If the input is a tuple `{:error, file}` where `file` is a binary, it attempts to parse the document from the file.
  - If the input is a binary `file`, it attempts to parse the document from the file.
  - For any other input, it returns the input as-is.

  ## Examples

    iex> parse({:error, "path/to/file"})
    # Parses the document from the given file

    iex> parse("path/to/file")
    # Parses the document from the given file

    iex> parse(:ok)
    :ok

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
      <<"PK", 0x03, 0x04, rest::binary>> -> parse_zip_file(rest, file)
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

  defp parse_docx(<<_::binary>>) do
    %Document{format: :docx}
  end

  defp parse_doc(<<_::binary>>) do
    %Document{format: :doc}
  end

  defp parse_odt(<<_::binary>>) do
    %Document{format: :odt}
  end

  defp parse_zip_file(<<_::binary-size(300), "word/", _::binary>>, file), do: parse_docx(file)
  defp parse_zip_file(_, file), do: parse_odt(file)
end
