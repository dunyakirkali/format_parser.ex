defmodule FormatParser.Data do
  alias __MODULE__

  @moduledoc """
  A Data struct and functions.

  The Data struct contains the fields format and nature.
  """

  defstruct [:format, nature: :data, intrinsics: %{}]
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
      _ -> {:error, file}
    end
  end

  defp parse_pqt(<<_x::binary>>) do
    %Data{format: :pqt}
  end
end
