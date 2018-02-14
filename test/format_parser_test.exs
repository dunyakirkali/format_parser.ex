defmodule FormatParserTest do
  use ExUnit.Case
  doctest FormatParser

  test "rtf" do
    {:ok, file} = File.read("priv/test.rtf")

    assert FormatParser.parse(file).format == :rtf
    assert FormatParser.parse(file).nature == :document
  end
  
  test "flv" do
    {:ok, file} = File.read("priv/test.flv")

    assert FormatParser.parse(file).format == :flv
    assert FormatParser.parse(file).nature == :video
    # assert FormatParser.parse(file).width_px == 360
    # assert FormatParser.parse(file).height_px == 288
  end
end
