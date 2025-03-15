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

  test "mp4" do
    {:ok, file} = File.read("priv/test.mp4")

    assert FormatParser.parse(file).format == :mp4
    assert FormatParser.parse(file).nature == :video
  end

  test "avi" do
    {:ok, file} = File.read("priv/test.avi")

    assert FormatParser.parse(file).format == :avi
    assert FormatParser.parse(file).nature == :video
  end

  test "wmv" do
    {:ok, file} = File.read("priv/test.wmv")

    assert FormatParser.parse(file).format == :wmv
    assert FormatParser.parse(file).nature == :video
  end

  test "mov" do
    {:ok, file} = File.read("priv/test.mov")

    assert FormatParser.parse(file).format == :mov
    assert FormatParser.parse(file).nature == :video
  end

  test "webm" do
    {:ok, file} = File.read("priv/test.webm")

    assert FormatParser.parse(file).format == :webm
    assert FormatParser.parse(file).nature == :video
  end

  test "mkv" do
    {:ok, file} = File.read("priv/test.mkv")

    assert FormatParser.parse(file).format == :mkv
    assert FormatParser.parse(file).nature == :video
  end
end
