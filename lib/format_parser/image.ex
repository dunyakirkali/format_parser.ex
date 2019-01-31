defmodule FormatParser.Image do
  alias __MODULE__

  @moduledoc """
  An Image struct and functions.

  The Image struct contains the fields format, width_px, height_px, intrinsics and nature.
  """

  defstruct [:format, :width_px, :height_px, nature: :image, intrinsics: %{}]

  @doc """
  Parses a file and extracts some information from it.

  Takes a `binary file` as argument.

  Returns a struct which contains all information that has been extracted from the file if the file is recognized.

  Returns the following tuple if file not recognized: `{:error, file}`.

  """
  def parse({:error, file}) when is_binary(file) do
    parse_image(file)
  end

  def parse(file) when is_binary(file) do
    parse_image(file)
  end

  def parse(result) do
    result
  end

  defp parse_image(file) do
    case file do
      <<0x89, "PNG", 0x0D, 0x0A, 0x1A, 0x0A, x :: binary>> -> parse_png(x)
      <<"BM", x :: binary>> -> parse_bmp(x)
      <<"GIF89a", x :: binary>> -> parse_gif(x)
      <<"GIF87a", x :: binary>> -> parse_gif(x)
      <<0xFF, 0xD8, 0xFF, x :: binary>> -> parse_jpeg(x)
      <<"II", 0x2A, 0x00, x :: binary>> -> parse_tif(x)
      <<"MM", 0x00, 0x2A, x :: binary>> -> parse_tif(x, true)
      <<0x00, 0x00, 0x01, 0x00, x :: binary>> -> parse_ico(x)
      <<0x00, 0x00, 0x02, 0x00, x :: binary>> -> parse_cur(x)
      <<"8BPS", x :: binary>> -> parse_psd(x)
      <<0x97, "JB2", 0x0D, 0x0A, 0x1A, 0x0A, x :: binary>> -> parse_jb2(x)
      <<"gimp xcf", x :: binary>> -> parse_xcf(x)
      <<0x76, 0x2F, 0x31, 0x01, x :: binary>> -> parse_exr(x)
      _ -> {:error, file}
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

  defp parse_psd(<<_ ::size(80), height :: size(32), width :: size(32), _ :: binary>>) do
    %Image{format: :psd, width_px: width, height_px: height}
  end

  defp parse_ico(<<_ :: size(16), width :: size(8), height :: size(8), num_color_palette :: size(8), 0x00, color_planes :: size(16), bits_per_pixel :: size(16), _ :: binary>>) do
    width_px = if width == 0, do: 256, else: width
    height_px = if height == 0, do: 256, else: height
    intrinsics = %{
      num_color_palette: num_color_palette,
      color_planes: color_planes,
      bits_per_pixel: bits_per_pixel
    }
    %Image{
      format: :ico,
      width_px: width_px,
      height_px: height_px,
      intrinsics: intrinsics
    }
  end

  defp parse_cur(<<_ :: size(16), width :: size(8), height :: size(8), num_color_palette :: size(8), 0x00, hotspot_horizontal_coords :: size(16), hotspot_vertical_coords :: size(16), _ :: binary>>) do
    width_px = if width == 0, do: 256, else: width
    height_px = if height == 0, do: 256, else: height
    intrinsics = %{
      num_color_palette: num_color_palette,
      hotspot_horizontal_coords: hotspot_horizontal_coords,
      hotspot_vertical_coords: hotspot_vertical_coords
    }
    %Image{
      format: :cur,
      width_px: width_px,
      height_px: height_px,
      intrinsics: intrinsics
    }
  end

  defp parse_tif(<< ifd0_offset :: little-integer-size(32), x :: binary >>) do
    ifd_0 = parse_ifd0(x, shift(ifd0_offset, 8), false)
    width = ifd_0[256].value
    height = ifd_0[257].value
    make = parse_make_tag(
      x,
      shift(ifd_0[271][:value], 8),
      shift(ifd_0[271][:length], 0)
    )
    model = parse_make_tag(
      x,
      shift(ifd_0[272][:value], 8),
      shift(ifd_0[272][:length], 0)
    )
    date_time = parse_make_tag(
      x,
      shift(ifd_0[306][:value], 8),
      shift(ifd_0[306][:length], 0)
    )
    intrinsics = %{
      preview_offset: ifd_0[273].value,
      preview_byte_count: ifd_0[279].value,
      model: model,
      date_time: date_time
    }

    cond do
     Regex.match?(~r/canon.+/i, make) ->
       %Image{
         format: :cr2,
         width_px: width,
         height_px: height,
         intrinsics: intrinsics
       }
     Regex.match?(~r/nikon.+/i, make) ->
       %Image{
         format: :nef,
         width_px: width,
         height_px: height,
         intrinsics: intrinsics
       }
     make == "" -> %Image{format: :tif, width_px: width, height_px: height}
    end
  end

  defp parse_tif(<< ifd0_offset :: big-integer-size(32), x :: binary>>, _) do
    ifd_0 = parse_ifd0(x, shift(ifd0_offset, 8), true)
    width = ifd_0[256].value
    height = ifd_0[257].value
    make = parse_make_tag(
      x,
      shift(ifd_0[271][:value], 8),
      shift(ifd_0[271][:length], 0)
    )
    if Regex.match?(~r/nikon.+/i, make) do
      %Image{format: :nef}
    else
      %Image{format: :tif, width_px: width, height_px: height}
    end
  end

  defp parse_ifd0(<< x :: binary >>, offset, big_endian)  when big_endian == false do
    <<_ :: size(offset), ifdc :: little-integer-size(16), rest :: binary>> = x
    ifds_sizes = ifdc * 12 * 8
    << ifd_set :: size(ifds_sizes), _ :: binary >> = rest
    parse_ifds(<< ifd_set :: size(ifds_sizes) >>, big_endian, %{})
  end

  defp parse_ifd0(<< x :: binary >>, offset, big_endian)  when big_endian == true do
    <<_ :: size(offset), ifd_count :: size(16), rest :: binary >> = x
    ifds_sizes = ifd_count * 12 * 8
    << ifd_set :: size(ifds_sizes), _ :: binary >> = rest
    parse_ifds(<< ifd_set :: size(ifds_sizes) >>, big_endian, %{})
  end

  defp parse_ifds(<<>>, _, accumulator), do: accumulator
  defp parse_ifds(<<x :: binary >>, big_endian, accumulator) do
    ifd = parse_ifd(<<x :: binary >>, big_endian)
    parse_ifds(ifd.ifd_left, big_endian, Map.merge(ifd, accumulator))
  end

  defp parse_ifd(<< tag :: little-integer-size(16), _ :: little-integer-size(16), length :: little-integer-size(32), value :: little-integer-size(32), ifd_left :: binary >>, big_endian) when big_endian == false do
    %{tag => %{tag: tag, length: length, value: value}, ifd_left: ifd_left}
  end

  defp parse_ifd(<< tag :: size(16), type :: size(16), length :: size(32), value :: size(32), ifd_left :: binary >>, big_endian) when big_endian == true and type != 3 do
    %{tag => %{tag: tag, length: length, value: value}, ifd_left: ifd_left}
  end

  defp parse_ifd(<< tag :: size(16), type :: size(16), length :: size(32), value :: size(32), ifd_left :: binary >>, big_endian) when big_endian == true and type == 3 do
    << value :: size(16), _ :: binary>> = << value :: size(32) >>
    %{tag => %{tag: tag, length: length, value: value}, ifd_left: ifd_left}
  end

  defp shift(offset, _) when is_nil(offset), do: 0
  defp shift(offset, byte), do: (offset - byte) * 8

  defp parse_make_tag(<< x ::binary >>, offset, len) do
    << _ :: size(offset), make_tag :: size(len), _ :: binary >> = x
    << make_tag :: size(len) >>
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

  defp parse_png(<< _ :: size(32), "IHDR", width :: size(32), height :: size(32), bit_depth, color_type, compression_method, filter_method, interlace_method, crc :: size(32), _ :: binary >>) do
    intrinsics = %{
      bit_depth: bit_depth,
      color_type: color_type,
      compression_method: compression_method,
      filter_method: filter_method,
      interlace_method: interlace_method,
      crc: crc
    }
    %Image{
      format: :png,
      width_px: width,
      height_px: height,
      intrinsics: intrinsics
    }
  end
end
