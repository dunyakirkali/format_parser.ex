defmodule FormatParser.VideoTest do
  use ExUnit.Case
  
  test "parse passed error" do
    {:ok, file} = File.read("priv/test.flv")

    assert FormatParser.Video.parse({:error, file}).format == :flv
  end
  
  test "parse file" do
    {:ok, file} = File.read("priv/test.flv")

    assert FormatParser.Video.parse(file).format == :flv
  end
  
  test "route passed result" do
    assert FormatParser.Document.parse(%FormatParser.Image{}) == %FormatParser.Image{}
  end
  
  test "flv" do
    {:ok, file} = File.read("priv/test.flv")

    assert FormatParser.parse(file).format == :flv
    assert FormatParser.parse(file).nature == :video
  end
end
