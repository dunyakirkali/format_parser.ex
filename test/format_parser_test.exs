defmodule FormatParserTest do
  use ExUnit.Case
  doctest FormatParser

  test "jpeg" do
    {:ok, file} = File.read("priv/test.jpg")

    assert FormatParser.parse(file).format == :jpg
    assert FormatParser.parse(file).nature == :image
    # assert FormatParser.parse(file).width_px == 313
    # assert FormatParser.parse(file).height_px == 234
  end
  
  test "gif" do
    {:ok, file} = File.read("priv/test.gif")

    assert FormatParser.parse(file).format == :gif
    assert FormatParser.parse(file).nature == :image
    assert FormatParser.parse(file).width_px == 600
    assert FormatParser.parse(file).height_px == 600
  end

  test "cr2" do
    {:ok, file} = File.read("priv/test.cr2")

    assert FormatParser.parse(file).format == :cr2
    assert FormatParser.parse(file).nature == :image
    # assert FormatParser.parse(file).width_px == 4368
    # assert FormatParser.parse(file).height_px == 2912
  end

  test "ico" do
    {:ok, file} = File.read("priv/test.ico")

    assert FormatParser.parse(file).format == :ico
    assert FormatParser.parse(file).nature == :image
    # assert FormatParser.parse(file).width_px == 256
    # assert FormatParser.parse(file).height_px == 256
  end

  test "rtf" do
    {:ok, file} = File.read("priv/test.rtf")

    assert FormatParser.parse(file).format == :rtf
    assert FormatParser.parse(file).nature == :document
  end

  test "tif" do
    {:ok, file} = File.read("priv/test.tif")

    assert FormatParser.parse(file).format == :tif
    assert FormatParser.parse(file).nature == :image
    # assert FormatParser.parse(file).width_px == 1728
    # assert FormatParser.parse(file).height_px == 2376
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
  end
  
  test "flv" do
    {:ok, file} = File.read("priv/test.flv")

    assert FormatParser.parse(file).format == :flv
    assert FormatParser.parse(file).nature == :video
    # assert FormatParser.parse(file).width_px == 360
    # assert FormatParser.parse(file).height_px == 288
  end
end
