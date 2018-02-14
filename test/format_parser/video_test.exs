defmodule FormatParser.VideoTest do
  use ExUnit.Case
  
  test "flv" do
    {:ok, file} = File.read("priv/test.flv")

    assert FormatParser.parse(file).format == :flv
    assert FormatParser.parse(file).nature == :video
    # assert FormatParser.parse(file).width_px == 360
    # assert FormatParser.parse(file).height_px == 288
  end
end
