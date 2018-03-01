defmodule FormatParser.DocumentTest do
  use ExUnit.Case

  test "parse passed error" do
    {:ok, file} = File.read("priv/test.rtf")

    assert FormatParser.Document.parse({:error, file}).format == :rtf
  end

  test "parse file" do
    {:ok, file} = File.read("priv/test.rtf")

    assert FormatParser.Document.parse(file).format == :rtf
  end

  test "route passed result" do
    assert FormatParser.Document.parse(%FormatParser.Audio{}) == %FormatParser.Audio{}
  end

  test "rtf" do
    {:ok, file} = File.read("priv/test.rtf")

    assert FormatParser.parse(file).format == :rtf
    assert FormatParser.parse(file).nature == :document
  end

  test "pdf" do
    {:ok, file} = File.read("priv/test.pdf")

    assert FormatParser.parse(file).format == :pdf
    assert FormatParser.parse(file).nature == :document
    assert FormatParser.parse(file).intrinsics[:page_count] == 1
  end
end
