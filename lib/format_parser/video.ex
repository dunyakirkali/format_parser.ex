defmodule FormatParser.Video do
  alias __MODULE__

  @moduledoc """
  A Video struct and functions.

  The Video struct contains the fields format, width_px, height_px and nature.
  """

  defstruct [:format, :width_px, :height_px, nature: :video]

  @doc """
  Parses a file and extracts some information from it.

  Takes a `binary file` as argument.

  Returns a struct which contains all information that has been extracted from the file if the file is recognized.

  Returns the following tuple if file not recognized: `{:error, file}`.

  """
  def parse({:error, file}) when is_binary(file) do
    parse_video(file)
  end

  def parse(file) when is_binary(file) do
    parse_video(file)
  end

  def parse(result) do
    result
  end

  defp parse_video(file) do
    case file do
      <<"FLV", 0x01, x::binary>> -> parse_flv(x)
      <<_::binary-size(4), "ftypmp4", _::binary>> -> parse_mp4(file)
      <<"RIFF", _::binary-size(4), "AVI ", _::binary>> -> parse_avi(file)
      _ -> {:error, file}
    end
  end

  defp parse_flv(<<_::binary>>) do
    %Video{format: :flv}
  end

  defp parse_mp4(<<_::binary>>) do
    %Video{format: :mp4}
  end

  defp parse_avi(<<_::binary>>) do
    %Video{format: :avi}
  end
end
