defmodule FormatParser.Archive do
  alias __MODULE__

  @moduledoc """
  An Archive struct and functions.

  The Archive struct contains the fields format and nature.
  """
  @type t :: %__MODULE__{
          format: any(),
          nature: atom(),
          intrinsics: map()
        }
  defstruct [:format, nature: :archive, intrinsics: %{}]

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
    parse_archive(file)
  end

  def parse(file) when is_binary(file) do
    parse_archive(file)
  end

  def parse(result) do
    result
  end

  defp parse_archive(file) do
    case file do
      <<_::size(0x8801 * 8), "CD001", x::binary>> -> parse_iso(x)
      _ -> {:error, file}
    end
  end

  defp parse_iso(<<_x::binary>>) do
    %Archive{format: :iso}
  end
end
