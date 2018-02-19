defmodule FormatParser do
  @moduledoc """
  The Format Parser
  """

  alias FormatParser.Image
  alias FormatParser.Video
  alias FormatParser.Document
  alias FormatParser.Audio
  alias FormatParser.Font

  @doc """
  Parses the format of a given file. Or returs an error if unknown.

  ## Examples

      iex> {:ok, file} = File.read("priv/test.jpg")
      iex> FormatParser.parse(file)
      %FormatParser.Image{format: :jpg, height_px: nil, nature: :image, width_px: nil}

  """
  @spec parse(binary) :: struct
  def parse(file) do
    case file do
      <<0x89, "PNG", 0x0D, 0x0A, 0x1A, 0x0A, x :: binary>> -> parse_png(x)
      <<"BM", x :: binary>> -> parse_bmp(x)
      <<"GIF89a", x :: binary>> -> parse_gif(x)
      <<"RIFF", x :: binary>> -> parse_wav(x)
      <<"OggS", x :: binary>> -> parse_ogg(x)
      <<"FORM", 0x00, x :: binary>> -> parse_aiff(x)
      <<"fLaC", x :: binary>> -> parse_flac(x)
      <<"FLV", 0x01, x :: binary>> -> parse_flv(x)
      <<"GIF87a", x :: binary>> -> parse_gif(x)
      <<0xFF, 0xD8, 0xFF, x :: binary>> -> parse_jpeg(x)
      <<0x49, 0x49, 0x2A, 0x00, 0x10, 0x00, 0x00, 0x00, 0x43, 0x52, 0x02, 0x00, x :: binary>> -> parse_cr2(x)
      <<0x49, 0x49, 0x2A, 0x00, x :: binary>> -> parse_tif(x)
      <<0x00, 0x00, 0x01, 0x00, x :: binary>> -> parse_ico(x)
      <<0x00, 0x00, 0x02, 0x00, x :: binary>> -> parse_cur(x)
      <<0x7B, 0x5C, 0x72, 0x74, 0x66, 0x31, x :: binary>> -> parse_rtf(x)
      <<0x00, 0x01, 0x00, 0x00, 0x00, x :: binary>> -> parse_ttf(x)
      <<"true", 0x00, x :: binary>> -> parse_ttf(x)
      <<"OTTO", 0x00, x :: binary>> -> parse_otf(x)
      <<"ID3", x :: binary>> -> parse_mp3(x)
      <<"8BPS", x :: binary>> -> parse_psd(x)
      <<0x4d, 0x5A, x :: binary>> -> parse_fon(x)
      _ -> {:error, "Unknown"}
    end
  end

  defp parse_fon(<<_x :: binary>>) do
    %Font{format: :fon}
  end

  defp parse_psd(<<_x :: binary>>) do
    %Image{format: :psd}
  end

  defp parse_mp3(<<_x :: binary>>) do
    %Audio{format: :mp3}
  end

  defp parse_otf(<<_x :: binary>>) do
    %Font{format: :otf}
  end

  defp parse_ttf(<<_x :: binary>>) do
    %Font{format: :ttf}
  end

  defp parse_rtf(<<_x :: binary>>) do
    %Document{format: :rtf}
  end

  defp parse_ico(<<_x :: size(16), width :: size(8), height :: size(8), _rest :: binary>>) do
    width_px = if (width == 0), do: 256, else: width
    height_px = if (height == 0), do: 256, else: height
    %Image{format: :ico, width_px: width_px, height_px: height_px}
  end

  defp parse_cur(<<_x :: size(16), width :: size(8), height :: size(8), _rest :: binary>>) do
    width_px = if (width == 0), do: 256, else: width
    height_px = if (height == 0), do: 256, else: height
    %Image{format: :cur, width_px: width_px, height_px: height_px}
  end

  defp parse_tif(<< exif_offset :: little-integer-size(32), x :: binary >>) do
    exif = parse_exif(x, shift(exif_offset, 8))
    make =
      if exif[271] do
        parse_string(x, shift(exif[271][:value], 8), shift(exif[271][:length], 0))
      else
        ""
      end

    if Regex.match?(~r/nikon .+/, make) do
      %Image{format: :nef, width_px: exif[256][:value], height_px: exif[257][:value]}
    else
      %Image{format: :tif, width_px: exif[256][:value], height_px: exif[257][:value]}
    end
  end

  defp parse_exif(<< x :: binary >>, offset) do
    << _ :: size(offset), size :: little-integer-size(16), rest :: binary >> = x
    ifds_size = size * 12 * 8
    << ifd_set :: size(ifds_size), _ :: binary >> = rest
    parse_ifds(<< ifd_set :: size(ifds_size) >>, %{})
  end

  defp parse_ifds(<<>>, accumulator), do: accumulator
  defp parse_ifds(<< tag :: little-integer-size(16), _ :: little-integer-size(16), length :: little-integer-size(32), value :: little-integer-size(32), ifd_left :: binary >>, accumulator) do
    ifd = %{tag => %{tag: tag, length: length, value: value}}
    parse_ifds(ifd_left, Map.merge(ifd, accumulator))
  end

  defp shift(offset, amount), do: (offset - amount) * 8

  defp parse_string(<< x ::binary >>, offset, length) do
    << _ :: size(offset), string :: size(length), _ :: binary >> = x
    << string :: size(length) >> |> String.downcase
  end

  defp parse_cr2(<< _cr2 :: little-integer-size(32), x :: binary >>) do
    exif = parse_exif(x, 0)
    %Image{format: :cr2, width_px: exif[256][:value], height_px: exif[257][:value]}
  end

  defp parse_flac(<<_x:: binary>>) do
    %Audio{format: :flac}
  end

  defp parse_ogg(<<_x:: binary>>) do
    %Audio{format: :ogg}
  end

  defp parse_wav(<<_ :: size(144), channels :: little-integer-size(16), sample_rate_hz :: little-integer-size(32), _x :: binary>>) do
    %Audio{format: :wav, sample_rate_hz: sample_rate_hz, num_audio_channels: channels}
  end

  defp parse_aiff(<<_ :: size(56), "COMM", _ :: size(96), sample_rate_hz :: size(80), _x :: binary>>) do
    %Audio{format: :aiff, sample_rate_hz: sample_rate_hz}
  end

  defp parse_flv(_x) do
    %Video{format: :flv}
  end

  defp parse_gif(<< width :: little-integer-size(16), height :: little-integer-size(16), _x :: binary>>) do
    %Image{format: :gif, width_px: width, height_px: height}
  end

  defp parse_jpeg(_binary) do
    %Image{format: :jpg}
  end

  defp parse_bmp(<< _header :: size(128), width :: little-integer-size(32), height :: little-integer-size(32), _x :: binary>>) do
    %Image{format: :bmp, width_px: width, height_px: height}
  end

  defp parse_png(<< _length :: size(32), "IHDR", width :: size(32), height :: size(32), _x :: binary>>) do
    %Image{format: :png, width_px: width, height_px: height}
  end
end
