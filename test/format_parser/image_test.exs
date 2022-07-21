defmodule FormatParser.ImageTest do
  use ExUnit.Case

  test "parse passed error" do
    {:ok, file} = File.read("priv/test.jpg")

    assert FormatParser.Image.parse({:error, file}).format == :jpg
  end

  test "parse file" do
    {:ok, file} = File.read("priv/test.jpg")

    assert FormatParser.Image.parse(file).format == :jpg
  end

  test "route passed result" do
    assert FormatParser.Document.parse(%FormatParser.Font{}) == %FormatParser.Font{}
  end

  test "jpeg" do
    {:ok, file} = File.read("priv/test.jpg")

    assert FormatParser.parse(file).format == :jpg
    assert FormatParser.parse(file).nature == :image
  end

  test "jb2" do
    {:ok, file} = File.read("priv/test.jb2")

    assert FormatParser.parse(file).format == :jb2
    assert FormatParser.parse(file).nature == :image
  end

  test "xcf" do
    {:ok, file} = File.read("priv/test.xcf")

    assert FormatParser.parse(file).format == :xcf
    assert FormatParser.parse(file).nature == :image
  end

  test "exr" do
    {:ok, file} = File.read("priv/test.exr")

    assert FormatParser.parse(file).format == :exr
    assert FormatParser.parse(file).nature == :image
  end

  test "gif" do
    {:ok, file} = File.read("priv/test.gif")

    assert FormatParser.parse(file).format == :gif
    assert FormatParser.parse(file).nature == :image
    assert FormatParser.parse(file).width_px == 600
    assert FormatParser.parse(file).height_px == 600
  end

  test "gif87a" do
    {:ok, file} = File.read("priv/test_2.gif")

    assert FormatParser.parse(file).format == :gif
    assert FormatParser.parse(file).nature == :image
    assert FormatParser.parse(file).width_px == 130
    assert FormatParser.parse(file).height_px == 42
  end

  test "cr2" do
    {:ok, file} = File.read("priv/test.cr2")

    assert FormatParser.parse(file).format == :cr2
    assert FormatParser.parse(file).nature == :image
    assert FormatParser.parse(file).width_px == 2496
    assert FormatParser.parse(file).height_px == 1664

    assert FormatParser.parse(file).intrinsics == %{
             preview_offset: 82_426,
             preview_byte_count: 733_952,
             model: "Canon EOS 5D" <> <<0>>,
             date_time: "2006:01:15 19:04:48" <> <<0>>
           }
  end

  test "nef" do
    {:ok, file} = File.read("priv/test.nef")

    assert FormatParser.parse(file).format == :nef
    assert FormatParser.parse(file).nature == :image
    assert FormatParser.parse(file).width_px == 212
    assert FormatParser.parse(file).height_px == 320

    assert FormatParser.parse(file).intrinsics == %{
             preview_offset: 25_370,
             preview_byte_count: 203_520,
             model: "NIKON D70" <> <<0>>,
             date_time: "2008:06:01 02:12:-1468006400" <> <<0>>
           }
  end

  test "nef big endian" do
    {:ok, file} = File.read("priv/test2.nef")

    assert FormatParser.parse(file).format == :nef
    assert FormatParser.parse(file).nature == :image
    # assert FormatParser.parse(file).width_px == 212
    # assert FormatParser.parse(file).height_px == 320
  end

  test "ico" do
    {:ok, file} = File.read("priv/test.ico")

    assert FormatParser.parse(file).format == :ico
    assert FormatParser.parse(file).nature == :image
    assert FormatParser.parse(file).width_px == 256
    assert FormatParser.parse(file).height_px == 256

    assert FormatParser.parse(file).intrinsics == %{
             num_color_palette: 0,
             color_planes: 256,
             bits_per_pixel: 8192
           }
  end

  test "cur" do
    {:ok, file} = File.read("priv/test.cur")

    assert FormatParser.parse(file).format == :cur
    assert FormatParser.parse(file).nature == :image
    assert FormatParser.parse(file).width_px == 32
    assert FormatParser.parse(file).height_px == 32

    assert FormatParser.parse(file).intrinsics == %{
             num_color_palette: 0,
             hotspot_horizontal_coords: 0,
             hotspot_vertical_coords: 0
           }
  end

  test "tif" do
    {:ok, file} = File.read("priv/test.tif")

    assert FormatParser.parse(file).format == :tif
    assert FormatParser.parse(file).nature == :image
    assert FormatParser.parse(file).width_px == 1728
    assert FormatParser.parse(file).height_px == 2376
  end

  test "tif big endian" do
    {:ok, file} = File.read("priv/test2.tif")

    assert FormatParser.parse(file).format == :tif
    assert FormatParser.parse(file).nature == :image
    assert FormatParser.parse(file).width_px == 320
    assert FormatParser.parse(file).height_px == 240
  end

  test "bmp" do
    {:ok, file} = File.read("priv/test.bmp")

    assert FormatParser.parse(file).format == :bmp
    assert FormatParser.parse(file).nature == :image
    assert FormatParser.parse(file).width_px == 124
    assert FormatParser.parse(file).height_px == 124
  end

  test "png" do
    {:ok, file} = File.read("priv/test.png")

    assert FormatParser.parse(file).format == :png
    assert FormatParser.parse(file).nature == :image
    assert FormatParser.parse(file).width_px == 300
    assert FormatParser.parse(file).height_px == 300

    assert FormatParser.parse(file).intrinsics == %{
             bit_depth: 8,
             color_type: 2,
             compression_method: 0,
             crc: 4_129_233_186,
             filter_method: 0,
             interlace_method: 0
           }
  end

  test "psd" do
    {:ok, file} = File.read("priv/test.psd")

    assert FormatParser.parse(file).format == :psd
    assert FormatParser.parse(file).nature == :image
    assert FormatParser.parse(file).width_px == 1023
    assert FormatParser.parse(file).height_px == 551
  end

  test "webp" do
    {:ok, file} = File.read("priv/test.webp")

    assert FormatParser.parse(file).format == :webp
    assert FormatParser.parse(file).nature == :image
  end
end
