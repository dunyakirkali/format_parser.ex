defmodule FormatParser do
  @moduledoc """

  FormatParser parses a binary file and extracts the format and some additional information from it.
  It can deal with Audio, Video, Fonts, Images and Documents.

  """

  alias FormatParser.{Image,Video,Document,Audio,Font}

  @doc """

  FormatParser.parse expects a binary file.
  If the file is recognized then it will return a struct which contains all
  information that has been extracted from the file.
  If the file is not recognized then it will return `{:error, "Unknown"}`.
  
  
  ## Parameters

    - binary: A binary file

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
      <<"MM", 0x00, 0x2A, x :: binary>> -> parse_tif(x, true)
      <<0x00, 0x00, 0x01, 0x00, x :: binary>> -> parse_ico(x)
      <<0x00, 0x00, 0x02, 0x00, x :: binary>> -> parse_cur(x)
      <<0x7B, 0x5C, 0x72, 0x74, 0x66, 0x31, x :: binary>> -> parse_rtf(x)
      <<0x00, 0x01, 0x00, 0x00, 0x00, x :: binary>> -> parse_ttf(x)
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

  defp parse_ico(<<_ :: size(16), width :: size(8), height :: size(8), num_color_palette :: size(8), 0x00, color_planes :: size(16), bits_per_pixel :: size(16), _ :: binary>>) do
    width_px = if (width == 0), do: 256, else: width
    height_px = if (height == 0), do: 256, else: height
    intrinsics = %{num_color_palette: num_color_palette, color_planes: color_planes, bits_per_pixel: bits_per_pixel}
    %Image{format: :ico, width_px: width_px, height_px: height_px, intrinsics: intrinsics}
  end

  defp parse_cur(<<_ :: size(16), width :: size(8), height :: size(8), num_color_palette :: size(8), 0x00, hotspot_horizontal_coords :: size(16), hotspot_vertical_coords :: size(16), _ :: binary>>) do
    width_px = if (width == 0), do: 256, else: width
    height_px = if (height == 0), do: 256, else: height
    intrinsics = %{num_color_palette: num_color_palette, hotspot_horizontal_coords: hotspot_horizontal_coords, hotspot_vertical_coords: hotspot_vertical_coords}
    %Image{format: :cur, width_px: width_px, height_px: height_px, intrinsics: intrinsics}
  end

  defp parse_tif(<< ifd0_offset :: little-integer-size(32), x :: binary >>) do
    ifd_0 = parse_ifd0(x, shift(ifd0_offset, 8), false)
    width = ifd_0[256].value
    height = ifd_0[257].value
    make = parse_make_tag(x, shift(ifd_0[271][:value], 8), shift(ifd_0[271][:length], 0))

    cond do
     Regex.match?(~r/canon.+/i, make) -> %Image{format: :cr2, width_px: width, height_px: height}
     Regex.match?(~r/nikon.+/i, make) -> %Image{format: :nef, width_px: width, height_px: height}
     make == "" -> %Image{format: :tif, width_px: width, height_px: height}
    end
  end

  defp parse_tif(<< ifd0_offset :: big-integer-size(32), x :: binary>>, big_endian) do
    ifd_0 = parse_ifd0(x, shift(ifd0_offset, 8), true)
    width = ifd_0[256].value
    height = ifd_0[257].value
    make = parse_make_tag(x, shift(ifd_0[271][:value], 8), shift(ifd_0[271][:length], 0))
    if Regex.match?(~r/nikon.+/i, make), do: %Image{format: :nef}, else: %Image{format: :tif, width_px: width, height_px: height}
  end

  defp parse_ifd0(<< x :: binary >>, offset, big_endian) do
    case big_endian do
      false -> <<_ :: size(offset), ifd_count :: little-integer-size(16), rest :: binary>> = x
      true -> <<_ :: size(offset), ifd_count :: size(16), rest :: binary >> = x
    end
    ifds_sizes = ifd_count * 12 * 8
    << ifd_set :: size(ifds_sizes), _ :: binary >> = rest
    parse_ifds(<< ifd_set :: size(ifds_sizes) >>, big_endian, %{})
  end

  defp parse_ifds(<<>>, big_endian, accumulator), do: accumulator
  defp parse_ifds(<<x :: binary >>, big_endian, accumulator) do
    ifd = parse_ifd(<<x :: binary >>, big_endian)
    parse_ifds(ifd.ifd_left, big_endian, Map.merge(ifd, accumulator))
  end

  defp parse_ifd(<<x :: binary>>, big_endian) do
    case big_endian do
      false ->
        << tag :: little-integer-size(16), _ :: little-integer-size(16), length :: little-integer-size(32), value :: little-integer-size(32), ifd_left :: binary >> = <<x :: binary>>
      true ->
        << tag :: size(16), type :: size(16), length :: size(32), value :: size(32), ifd_left :: binary >> = <<x :: binary>>
        if type == 3, do: << value :: size(16), _ :: binary>> = << value :: size(32) >>
    end
    %{tag => %{tag: tag, length: length, value: value}, ifd_left: ifd_left}
  end

  defp shift(offset, _) when is_nil(offset), do: 0
  defp shift(offset, byte), do: (offset - byte) * 8

  defp parse_make_tag(<< x ::binary >>, offset, len) do
    << _ :: size(offset), make_tag :: size(len), _ :: binary >> = x
    << make_tag :: size(len) >>
  end

  defp parse_flac(<<_ :: size(112), sample_rate_hz :: size(20), num_audio_channels :: size(3), _ :: size(5), _ :: size(36), _ :: binary>>) do
    %Audio{format: :flac, sample_rate_hz: sample_rate_hz, num_audio_channels: num_audio_channels}
  end

  defp parse_ogg(<<_ :: size(280), channels :: little-integer-size(8), sample_rate_hz :: little-integer-size(32), _ :: binary>>) do
    %Audio{format: :ogg, sample_rate_hz: sample_rate_hz, num_audio_channels: channels}
  end

  defp parse_wav(<<_ :: size(144), channels :: little-integer-size(16), sample_rate_hz :: little-integer-size(32), byte_rate :: little-integer-size(32), block_align :: little-integer-size(16), bits_per_sample :: little-integer-size(16), _ :: binary>>) do
    intrinsics = %{byte_rate: byte_rate, block_align: block_align, bits_per_sample: bits_per_sample}
    %Audio{format: :wav, sample_rate_hz: sample_rate_hz, num_audio_channels: channels, intrinsics: intrinsics}
  end

  defp parse_aiff(<<_ :: size(56), "COMM", _ :: size(32), channels :: size(16), frames :: size(32), bits_per_sample :: size(16), _sample_rate_components :: size(80), _ :: binary>>) do
    intrinsics = %{num_frames: frames, bits_per_sample: bits_per_sample}
    %Audio{format: :aiff, num_audio_channels: channels, intrinsics: intrinsics}
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
  
  defp parse_png(<< _ :: size(32), "IHDR", width :: size(32), height :: size(32), bit_depth, color_type, compression_method, filter_method, interlace_method, crc :: size(32), chunks :: binary >>) do
    intrinsics = %{bit_depth: bit_depth, color_type: color_type, compression_method: compression_method, filter_method: filter_method, interlace_method: interlace_method, crc: crc}
    %Image{format: :png, width_px: width, height_px: height, intrinsics: intrinsics}
  end
end
