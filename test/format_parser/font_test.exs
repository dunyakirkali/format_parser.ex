defmodule FormatParser.FontTest do
  use ExUnit.Case

  test "ttf" do
    {:ok, file} = File.read("priv/test.ttf")

    assert FormatParser.parse(file).format == :ttf
    assert FormatParser.parse(file).nature == :font
  end

  test "otf" do
    {:ok, file} = File.read("priv/test.otf")

    assert FormatParser.parse(file).format == :otf
    assert FormatParser.parse(file).nature == :font
  end

  test "fon" do
    {:ok, file} = File.read("priv/test.fon")

    assert FormatParser.parse(file).format == :fon
    assert FormatParser.parse(file).nature == :font
  end
end
