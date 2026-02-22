defmodule FormatParser.Data do
  alias __MODULE__

  @moduledoc """
  A Data struct and functions.

  The Data struct contains the fields format and nature.
  """
  @type t :: %__MODULE__{
          format: any(),
          nature: atom(),
          intrinsics: map()
        }
  defstruct [:format, nature: :data, intrinsics: %{}]

  @doc """
  Parses the given input based on its type.

  - If the input is a tuple `{:error, file}` where `file` is a binary, it attempts to parse the file data.
  - If the input is a binary, it parses the file data.
  - For any other input, it returns the input as is.

  ## Examples

    iex> parse({:error, "file.txt"})
    # Parses the file data

    iex> parse("file.txt")
    # Parses the file data

    iex> parse(:ok)
    :ok

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
