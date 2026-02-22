defmodule FormatParser.Data do
  alias __MODULE__

  @moduledoc """
  A Data struct and functions for parsing data file formats.

  The Data struct contains the fields format, nature, and intrinsics.

  ## Supported Formats

  | Format   | Extension | Description                    |
  |----------|-----------|--------------------------------|
  | `:pqt`   | .parquet  | Apache Parquet columnar format |
  | `:sqlite3` | .db, .sqlite | SQLite 3 database         |
  | `:duckdb` | .duckdb  | DuckDB database                |
  | `:arrow` | .arrow    | Apache Arrow IPC file format   |
  | `:feather` | .feather | Feather V1 format            |

  ## Examples

      iex> {:ok, file} = File.read("data.parquet")
      iex> result = FormatParser.Data.parse(file)
      %FormatParser.Data{format: :pqt, nature: :data, intrinsics: %{}}

  """

  @typedoc """
  A struct representing a parsed data file.

  ## Fields

    * `:format` - The detected data format (e.g., `:pqt`, `:sqlite3`, `:duckdb`, `:arrow`, `:feather`)
    * `:nature` - Always `:data` for data files
    * `:intrinsics` - A map containing format-specific metadata

  """
  @type t :: %__MODULE__{
          format: atom() | nil,
          nature: :data,
          intrinsics: map()
        }
  defstruct [:format, nature: :data, intrinsics: %{}]

  @doc """
  Parses binary data to detect data file formats.

  This function attempts to identify data formats by examining magic bytes
  at the beginning of the binary content.

  ## Arguments

    * `input` - Can be one of:
      * `{:error, binary}` - A tuple containing binary file content (used in parser chain)
      * `binary` - Raw binary file content
      * `any` - Any other value is returned as-is (pass-through for parser chain)

  ## Returns

    * `%FormatParser.Data{}` - When a supported data format is detected
    * `{:error, binary}` - When the format is not recognized (for parser chain)
    * The input unchanged - When input is neither a binary nor an error tuple

  ## Examples

      iex> {:ok, file} = File.read("priv/test.parquet")
      iex> FormatParser.Data.parse(file)
      %FormatParser.Data{format: :pqt, nature: :data, intrinsics: %{}}

      iex> FormatParser.Data.parse({:error, <<80, 65, 82, 49, 0>>})
      %FormatParser.Data{format: :pqt, nature: :data, intrinsics: %{}}

      iex> FormatParser.Data.parse(%FormatParser.Image{})
      %FormatParser.Image{}

  """
  @spec parse({:error, binary()} | binary() | any()) :: any()
  def parse({:error, file}) when is_binary(file) do
    parse_data(file)
  end

  def parse(file) when is_binary(file) do
    parse_data(file)
  end

  def parse(result) do
    result
  end

  defp parse_data(file) do
    case file do
      <<"PAR1", x::binary>> -> parse_pqt(x)
      <<"SQLite format 3", x::binary>> -> parse_sqlite3(x)
      <<_::binary-size(8), "DUCK", x::binary>> -> parse_duckdb(x)
      <<"ARROW1", x::binary>> -> parse_arrow(x)
      <<"FEA1", x::binary>> -> parse_feather_v1(x)
      _ -> {:error, file}
    end
  end

  defp parse_pqt(<<_x::binary>>) do
    %Data{format: :pqt}
  end

  defp parse_duckdb(<<_x::binary>>) do
    %Data{format: :duckdb}
  end

  defp parse_sqlite3(<<_x::binary>>) do
    %Data{format: :sqlite3}
  end

  # Apache Arrow IPC File Format (also used by Feather V2)
  # Magic: "ARROW1" at start and end of file
  defp parse_arrow(<<_x::binary>>) do
    %Data{format: :arrow}
  end

  # Legacy Feather V1 format
  # Magic: "FEA1" at start of file
  defp parse_feather_v1(<<_x::binary>>) do
    %Data{format: :feather}
  end
end
