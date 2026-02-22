defmodule FormatParser.Video do
  alias __MODULE__

  @moduledoc """
  A Video struct and functions.

  The Video struct contains the fields format, width_px, height_px and nature.

  ## Supported Formats

  - FLV (Flash Video)
  - MP4 (MPEG-4 Part 14)
  - AVI (Audio Video Interleave)
  - WMV (Windows Media Video)
  - MOV (QuickTime)
  - WebM
  - MKV (Matroska)
  """

  @typedoc """
  A struct representing a parsed video file.

  ## Fields

  - `:format` - The video format as an atom (e.g., `:mp4`, `:mkv`, `:webm`)
  - `:width_px` - The video width in pixels (if available)
  - `:height_px` - The video height in pixels (if available)
  - `:nature` - Always `:video` for video files
  """
  @type t :: %Video{
          format: atom() | nil,
          width_px: integer() | nil,
          height_px: integer() | nil,
          nature: atom()
        }
  defstruct [:format, :width_px, :height_px, nature: :video]

  @doc """
  Parses a video file or result.

  - If given a tuple `{:error, file}` where `file` is a binary, attempts to parse the video file.
  - If given a binary `file`, attempts to parse the video file.
  - For any other input, returns the input as-is.

  ## Examples

      iex> {:ok, file} = File.read("priv/test.mp4")
      iex> result = FormatParser.Video.parse(file)
      iex> result.format
      :mp4
      iex> result.nature
      :video

      iex> FormatParser.Video.parse(%FormatParser.Image{})
      %FormatParser.Image{}

  """
  @spec parse({:error, binary()} | binary() | any()) :: any()
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
      <<0x30, 0x26, 0xB2, 0x75, _::binary>> -> parse_wmv(file)
      <<_::binary-size(4), "ftypqt", _::binary>> -> parse_mov(file)
      <<0x1A, 0x45, 0xDF, 0xA3, rest::binary>> -> parse_matroska(rest, file)
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

  defp parse_wmv(<<_::binary>>) do
    %Video{format: :wmv}
  end

  defp parse_mov(<<_::binary>>) do
    %Video{format: :mov}
  end

  defp parse_webm(<<_::binary>>) do
    %Video{format: :webm}
  end

  defp parse_mkv(<<_::binary>>) do
    %Video{format: :mkv}
  end

  defp parse_matroska(<<_::binary-size(27), "webm", _::binary>>, file), do: parse_webm(file)
  defp parse_matroska(_, file), do: parse_mkv(file)
end
