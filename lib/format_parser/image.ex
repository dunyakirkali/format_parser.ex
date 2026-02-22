defmodule FormatParser.Image do
  alias __MODULE__

  @moduledoc """
  An Image struct and functions.

  The Image struct contains the fields format, width_px, height_px, intrinsics and nature.

  ## Supported Formats

  | Format | Extension | Width/Height | Intrinsics |
  |--------|-----------|:------------:|------------|
  | `:png` | .png | ✓ | bit_depth, color_type, compression_method, filter_method, interlace_method, crc |
  | `:jpg` | .jpg, .jpeg | ✓ | - |
  | `:gif` | .gif | ✓ | - |
  | `:bmp` | .bmp | ✓ | - |
  | `:tif` | .tif, .tiff | ✓ | - |
  | `:psd` | .psd | ✓ | - |
  | `:ico` | .ico | ✓ | num_color_palette, color_planes, bits_per_pixel |
  | `:cur` | .cur | ✓ | num_color_palette, hotspot_horizontal_coords, hotspot_vertical_coords |
  | `:cr2` | .cr2 | ✓ | date_time, model, preview_byte_count, preview_offset |
  | `:nef` | .nef | ✓ | date_time, model, preview_byte_count, preview_offset |
  | `:webp` | .webp | - | - |
  | `:heic` | .heic | - | - |
  | `:avif` | .avif | - | - |
  | `:svg` | .svg | - | - |
  | `:jb2` | .jb2 | - | - |
  | `:xcf` | .xcf | - | - |
  | `:exr` | .exr | - | - |

  """

  @typedoc """
  A struct representing a parsed image file.

  ## Fields

    * `:format` - The image format as an atom (e.g., `:png`, `:jpg`, `:gif`)
    * `:width_px` - The image width in pixels, or `nil` if not available
    * `:height_px` - The image height in pixels, or `nil` if not available
    * `:nature` - Always `:image` for image files
    * `:intrinsics` - A map containing format-specific metadata

  """

  @type t :: %Image{
          format: atom() | nil,
          width_px: integer() | nil,
          height_px: integer() | nil,
          nature: atom(),
          intrinsics: map()
        }
  defstruct [:format, :width_px, :height_px, nature: :image, intrinsics: %{}]

  @doc """
  Parses an image file or result.

  - If given a tuple `{:error, file}` where `file` is a binary, attempts to parse the image from the file.
  - If given a binary `file`, attempts to parse the image from the file.
  - For any other input, returns the input as-is.

  ## Examples

    iex> parse("image.png")
    # Parsed image result

    iex> parse({:error, "image.png"})
    # Parsed image result

    iex> parse(:some_other_result)
    :some_other_result

  """
  @spec parse({:error, binary()} | binary() | any()) :: any()
  def parse({:error, file}) when is_binary(file) do
    parse_image(file)
  end

  def parse(file) when is_binary(file) do
    parse_image(file)
  end

  def parse(result) do
    result
  end

  # credo:disable-for-lines:18 Credo.Check.Refactor.CyclomaticComplexity
  defp parse_image(file) do
    case file do
      <<0x89, "PNG", 0x0D, 0x0A, 0x1A, 0x0A, x::binary>> -> parse_png(x)
      <<"BM", x::binary>> -> parse_bmp(x)
      <<"GIF89a", x::binary>> -> parse_gif(x)
      <<"GIF87a", x::binary>> -> parse_gif(x)
      <<0xFF, 0xD8, 0xFF, x::binary>> -> parse_jpeg(x)
      <<"II", 0x2A, 0x00, x::binary>> -> parse_tif(x)
      <<"MM", 0x00, 0x2A, x::binary>> -> parse_tif(x, true)
      <<0x00, 0x00, 0x01, 0x00, x::binary>> -> parse_ico(x)
      <<0x00, 0x00, 0x02, 0x00, x::binary>> -> parse_cur(x)
      <<"8BPS", x::binary>> -> parse_psd(x)
      <<0x97, "JB2", 0x0D, 0x0A, 0x1A, 0x0A, x::binary>> -> parse_jb2(x)
      <<"gimp xcf", x::binary>> -> parse_xcf(x)
      <<0x76, 0x2F, 0x31, 0x01, x::binary>> -> parse_exr(x)
      <<"RIFF", _::binary-size(4), "WEBP", x::binary>> -> parse_webp(x)
      <<_::binary-size(4), "ftypheic", x::binary>> -> parse_heic(x)
      <<_::binary-size(4), "ftypavif", x::binary>> -> parse_avif(x)
      <<_::binary-size(4), "ftypavis", x::binary>> -> parse_avif(x)
      <<"<svg", _::binary>> -> parse_svg(file)
      _ -> {:error, file}
    end
  end

  defp parse_exr(<<_::binary>>) do
    %Image{format: :exr}
  end

  defp parse_xcf(<<_::binary>>) do
    %Image{format: :xcf}
  end

  defp parse_jb2(<<_::binary>>) do
    %Image{format: :jb2}
  end

  defp parse_webp(<<_::binary>>) do
    %Image{format: :webp}
  end

  defp parse_psd(<<_::size(80), height::size(32), width::size(32), _::binary>>) do
    %Image{format: :psd, width_px: width, height_px: height}
  end

  defp parse_ico(
         <<_::size(16), width::size(8), height::size(8), num_color_palette::size(8), 0x00,
           color_planes::size(16), bits_per_pixel::size(16), _::binary>>
       ) do
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

  defp parse_cur(
         <<_::size(16), width::size(8), height::size(8), num_color_palette::size(8), 0x00,
           hotspot_horizontal_coords::size(16), hotspot_vertical_coords::size(16), _::binary>>
       ) do
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

  defp parse_tif(<<ifd0_offset::little-integer-size(32), x::binary>>) do
    ifd_0 = parse_ifd0(x, shift(ifd0_offset, 8), false)
    width = ifd_0[256].value
    height = ifd_0[257].value

    make =
      parse_make_tag(
        x,
        shift(ifd_0[271][:value], 8),
        shift(ifd_0[271][:length], 0)
      )

    model =
      parse_make_tag(
        x,
        shift(ifd_0[272][:value], 8),
        shift(ifd_0[272][:length], 0)
      )

    date_time =
      parse_make_tag(
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

      make == "" ->
        %Image{format: :tif, width_px: width, height_px: height}
    end
  end

  defp parse_tif(<<ifd0_offset::big-integer-size(32), x::binary>>, _) do
    ifd_0 = parse_ifd0(x, shift(ifd0_offset, 8), true)
    width = ifd_0[256].value
    height = ifd_0[257].value

    make =
      parse_make_tag(
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

  defp parse_ifd0(<<x::binary>>, offset, big_endian) when big_endian == false do
    <<_::size(offset), ifdc::little-integer-size(16), rest::binary>> = x
    ifds_sizes = ifdc * 12 * 8
    <<ifd_set::size(ifds_sizes), _::binary>> = rest
    parse_ifds(<<ifd_set::size(ifds_sizes)>>, big_endian, %{})
  end

  defp parse_ifd0(<<x::binary>>, offset, big_endian) when big_endian == true do
    <<_::size(offset), ifd_count::size(16), rest::binary>> = x
    ifds_sizes = ifd_count * 12 * 8
    <<ifd_set::size(ifds_sizes), _::binary>> = rest
    parse_ifds(<<ifd_set::size(ifds_sizes)>>, big_endian, %{})
  end

  defp parse_ifds(<<>>, _, accumulator), do: accumulator

  defp parse_ifds(<<x::binary>>, big_endian, accumulator) do
    ifd = parse_ifd(<<x::binary>>, big_endian)
    parse_ifds(ifd.ifd_left, big_endian, Map.merge(ifd, accumulator))
  end

  defp parse_ifd(
         <<tag::little-integer-size(16), _::little-integer-size(16),
           length::little-integer-size(32), value::little-integer-size(32), ifd_left::binary>>,
         big_endian
       )
       when big_endian == false do
    %{tag => %{tag: tag, length: length, value: value}, ifd_left: ifd_left}
  end

  defp parse_ifd(
         <<tag::size(16), type::size(16), length::size(32), value::size(32), ifd_left::binary>>,
         big_endian
       )
       when big_endian == true and type != 3 do
    %{tag => %{tag: tag, length: length, value: value}, ifd_left: ifd_left}
  end

  defp parse_ifd(
         <<tag::size(16), type::size(16), length::size(32), value::size(32), ifd_left::binary>>,
         big_endian
       )
       when big_endian == true and type == 3 do
    <<value::size(16), _::binary>> = <<value::size(32)>>
    %{tag => %{tag: tag, length: length, value: value}, ifd_left: ifd_left}
  end

  defp shift(offset, _) when is_nil(offset), do: 0
  defp shift(offset, byte), do: (offset - byte) * 8

  defp parse_make_tag(<<x::binary>>, offset, len) do
    <<_::size(offset), make_tag::size(len), _::binary>> = x
    <<make_tag::size(len)>>
  end

  defp parse_gif(<<width::little-integer-size(16), height::little-integer-size(16), _::binary>>) do
    %Image{format: :gif, width_px: width, height_px: height}
  end

  defp parse_jpeg(data) do
    case find_jpeg_dimensions(data) do
      {width, height} ->
        %Image{format: :jpg, width_px: width, height_px: height}

      nil ->
        %Image{format: :jpg}
    end
  end

  # JPEG SOF markers that contain image dimensions
  # SOF0 (0xC0) - Baseline DCT
  # SOF1 (0xC1) - Extended sequential DCT
  # SOF2 (0xC2) - Progressive DCT
  # SOF3 (0xC3) - Lossless (sequential)
  # SOF5 (0xC5) - Differential sequential DCT
  # SOF6 (0xC6) - Differential progressive DCT
  # SOF7 (0xC7) - Differential lossless (sequential)
  # SOF9 (0xC9) - Extended sequential DCT, arithmetic coding
  # SOF10 (0xCA) - Progressive DCT, arithmetic coding
  # SOF11 (0xCB) - Lossless (sequential), arithmetic coding
  # SOF13 (0xCD) - Differential sequential DCT, arithmetic coding
  # SOF14 (0xCE) - Differential progressive DCT, arithmetic coding
  # SOF15 (0xCF) - Differential lossless, arithmetic coding
  @sof_markers [0xC0, 0xC1, 0xC2, 0xC3, 0xC5, 0xC6, 0xC7, 0xC9, 0xCA, 0xCB, 0xCD, 0xCE, 0xCF]

  defp find_jpeg_dimensions(<<>>) do
    nil
  end

  defp find_jpeg_dimensions(<<0xFF, marker, _length::size(16), _precision::size(8),
                              height::size(16), width::size(16), _rest::binary>>)
       when marker in @sof_markers do
    {width, height}
  end

  defp find_jpeg_dimensions(<<0xFF, marker, length::size(16), rest::binary>>)
       when marker != 0x00 and marker != 0xFF do
    # Skip this segment (length includes the 2 bytes for length itself)
    skip_bytes = length - 2

    case rest do
      <<_skipped::binary-size(skip_bytes), remaining::binary>> ->
        find_jpeg_dimensions(remaining)

      _ ->
        nil
    end
  end

  defp find_jpeg_dimensions(<<0xFF, 0xFF, rest::binary>>) do
    # Multiple 0xFF bytes (padding), keep looking
    find_jpeg_dimensions(<<0xFF, rest::binary>>)
  end

  defp find_jpeg_dimensions(<<0xFF, 0x00, rest::binary>>) do
    # Stuffed byte, skip it
    find_jpeg_dimensions(rest)
  end

  defp find_jpeg_dimensions(<<_, rest::binary>>) do
    find_jpeg_dimensions(rest)
  end

  defp parse_bmp(
         <<_::size(128), width::little-integer-size(32), height::little-integer-size(32),
           _::binary>>
       ) do
    %Image{format: :bmp, width_px: width, height_px: height}
  end

  defp parse_png(
         <<_::size(32), "IHDR", width::size(32), height::size(32), bit_depth, color_type,
           compression_method, filter_method, interlace_method, crc::size(32), _::binary>>
       ) do
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

  defp parse_heic(<<_::binary>>) do
    %Image{format: :heic}
  end

  defp parse_avif(<<_::binary>>) do
    %Image{format: :avif}
  end

  defp parse_svg(<<_::binary>>) do
    %Image{format: :svg}
  end
end
