defmodule FormatParserTest do
  use ExUnit.Case
  doctest FormatParser

  test "jpeg" do
    {:ok, file} = File.read("test/fixtures/JPEG_example_JPG_RIP_050.jpg")

    assert FormatParser.parse(file).format == :jpeg
    assert FormatParser.parse(file).nature == :image
  end

  test "cr2" do
    {:ok, file} = File.read("test/fixtures/RAW_CANON_5D_ARGB.CR2")

    assert FormatParser.parse(file).format == :cr2
    assert FormatParser.parse(file).nature == :image
  end

  test "ico" do
    {:ok, file} = File.read("test/fixtures/Sora-Meliae-Matrilineare-Mimes-image-x-ico.ico")

    assert FormatParser.parse(file).format == :ico
    assert FormatParser.parse(file).nature == :image
  end

  test "rtf" do
    {:ok, file} = File.read("test/fixtures/rich_text.rtf")

    assert FormatParser.parse(file).format == :rtf
    assert FormatParser.parse(file).nature == :text
  end

  test "tif" do
    {:ok, file} = File.read("test/fixtures/CCITT_8.TIF")

    assert FormatParser.parse(file).format == :tif
    assert FormatParser.parse(file).nature == :image
  end

  test "bmp" do
    {:ok, file} = File.read("test/fixtures/FLAG_B24.bmp")

    assert FormatParser.parse(file).format == :bmp
    assert FormatParser.parse(file).nature == :image
  end
end
