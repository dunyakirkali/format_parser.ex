defmodule FormatParser do
  @moduledoc """
  The Format Parser
  """

  alias FormatParser.{Image,Video,Document,Audio,Font}

  @doc """
  Parses the format of a given file. Or returs an error if unknown.

  ## Examples

      iex> {:ok, file} = File.read("priv/test.jpg")
      iex> FormatParser.parse(file)
      %FormatParser.Image{format: :jpg, height_px: nil, nature: :image, width_px: nil}

      iex> {:ok, file} = File.read("priv/test.html")
      iex> FormatParser.parse(file)
      {:error, "Unknown"}

  """
  @spec parse(binary) :: struct
  def parse(file) when is_binary(file) do
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
      <<"II", 0x2A, 0x00, x :: binary>> -> parse_tif(x)
      <<0x00, 0x00, 0x01, 0x00, x :: binary>> -> parse_ico(x)
      <<0x00, 0x00, 0x02, 0x00, x :: binary>> -> parse_cur(x)
      <<0x7B, 0x5C, 0x72, 0x74, 0x66, 0x31, x :: binary>> -> parse_rtf(x)
      <<0x00, 0x01, 0x00, 0x00, 0x00, x :: binary>> -> parse_ttf(x)
      <<"true", 0x00, x :: binary>> -> parse_ttf(x)
      <<"OTTO", 0x00, x :: binary>> -> parse_otf(x)
      <<"ID3", x :: binary>> -> parse_mp3(x)
      <<"8BPS", x :: binary>> -> parse_psd(x)
      <<0x4d, 0x5A, x :: binary>> -> parse_fon(x)
      <<0x97, 0x4A, 0x42, 0x32, 0x0D, 0x0A, 0x1A, 0x0A, x :: binary>> -> parse_jb2(x)
      <<"gimp xcf", x :: binary>> -> parse_xcf(x)
      <<0x76, 0x2F, 0x31, 0x01, x :: binary>> -> parse_exr(x)
      _ -> {:error, "Unknown"}
    end
  end
  
  defp parse_exr(<<_ :: binary>>) do
    %Image{format: :exr}
  end
  
  defp parse_xcf(<<_ :: binary>>) do
    %Image{format: :xcf}
  end
  
  defp parse_jb2(<<_ :: binary>>) do
    %Image{format: :jb2}
  end

  defp parse_fon(<<_ :: binary>>) do
    %Font{format: :fon}
  end

  defp parse_psd(<<_ ::size(80), height :: size(32), width :: size(32), _ :: binary>>) do
    %Image{format: :psd, width_px: width, height_px: height}
  end

  defp parse_mp3(<<_ :: binary>>) do
    %Audio{format: :mp3}
  end

  defp parse_otf(<<_ :: binary>>) do
    %Font{format: :otf}
  end

  defp parse_ttf(<<_x :: binary>>) do
    %Font{format: :ttf}
  end

  defp parse_rtf(<<_x :: binary>>) do
    %Document{format: :rtf}
  end

  defp parse_ico(<<_ :: size(16), width :: size(8), height :: size(8), _ :: binary>>) do
    width_px = if (width == 0), do: 256, else: width
    height_px = if (height == 0), do: 256, else: height
    %Image{format: :ico, width_px: width_px, height_px: height_px}
  end

  defp parse_cur(<<_ :: size(16), width :: size(8), height :: size(8), _ :: binary>>) do
    width_px = if (width == 0), do: 256, else: width
    height_px = if (height == 0), do: 256, else: height
    %Image{format: :cur, width_px: width_px, height_px: height_px}
  end

  defp parse_tif(<< exif_offset :: little-integer-size(32), x :: binary >>) do
    exif = parse_exif(x, shift(exif_offset, 8))
    width = exif[256]
    height = exif[257]
    make = parse_make_tag(x, shift(exif[271][:value], 8), shift(exif[271][:length], 0))

    cond do
     Regex.match?(~r/canon.+/i, make) -> %Image{format: :cr2, width_px: width[:value], height_px: height[:value]}
     Regex.match?(~r/nikon.+/i, make) -> %Image{format: :nef, width_px: width[:value], height_px: height[:value]}
     make == "" -> %Image{format: :tif, width_px: width[:value], height_px: height[:value]}
    end
  end

  defp parse_exif(<< x :: binary >>, offset) do
    << _ :: size(offset), ifd_count :: little-integer-size(16), rest :: binary >> = x
    ifds_sizes = ifd_count * 12 * 8
    << ifd_set :: size(ifds_sizes), _ :: binary >> = rest
    parse_ifds(<< ifd_set :: size(ifds_sizes) >>, %{})
  end

  defp parse_ifds(<<>>, accumulator), do: accumulator
  defp parse_ifds(<< tag :: little-integer-size(16), _ :: little-integer-size(16), length :: little-integer-size(32), value :: little-integer-size(32), ifd_left :: binary >>, accumulator) do
    ifd = %{tag => %{tag: tag, length: length, value: value}}
    parse_ifds(ifd_left, Map.merge(ifd, accumulator))
  end

  defp shift(offset, _) when is_nil(offset), do: 0
  defp shift(offset, byte), do: (offset - byte) * 8

  defp parse_make_tag(<< x ::binary >>, offset, len) do
    << _ :: size(offset), make_tag :: size(len), _ :: binary >> = x
    << make_tag :: size(len) >>
  end

  defp parse_flac(<<_ :: binary>>) do
    %Audio{format: :flac}
  end

  defp parse_ogg(<<_ :: binary>>) do
    %Audio{format: :ogg}
  end

  defp parse_wav(<<_ :: size(144), channels :: little-integer-size(16), sample_rate_hz :: little-integer-size(32), _ :: binary>>) do
    %Audio{format: :wav, sample_rate_hz: sample_rate_hz, num_audio_channels: channels}
  end

  defp parse_aiff(<<_ :: size(56), "COMM", _ :: size(96), sample_rate_hz :: size(80), _ :: binary>>) do
    %Audio{format: :aiff, sample_rate_hz: sample_rate_hz}
  end

  defp parse_flv(<<_ :: binary>>) do
    %Video{format: :flv}
  end

  defp parse_gif(<< width :: little-integer-size(16), height :: little-integer-size(16), _ :: binary>>) do
    %Image{format: :gif, width_px: width, height_px: height}
  end

  defp parse_jpeg(<<_ :: binary>>) do
    %Image{format: :jpg}
  end

  defp parse_bmp(<< _ :: size(128), width :: little-integer-size(32), height :: little-integer-size(32), _ :: binary>>) do
    %Image{format: :bmp, width_px: width, height_px: height}
  end

  defp parse_png(<< _ :: size(32), "IHDR", width :: size(32), height :: size(32), _ :: binary>>) do
    %Image{format: :png, width_px: width, height_px: height}
  end
end
