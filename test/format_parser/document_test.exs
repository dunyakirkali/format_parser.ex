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
    Path.wildcard("priv/pdf/*.pdf")
    |> Enum.each(fn x ->
      {:ok, file} = File.read(x)

      assert FormatParser.parse(file).format == :pdf
      assert FormatParser.parse(file).nature == :document
      assert FormatParser.parse(file).intrinsics[:page_count] == 1
    end)
  end

  test "docx" do
    {:ok, file} = File.read("priv/test.docx")

    assert FormatParser.parse(file).format == :docx
    assert FormatParser.parse(file).nature == :document
  end

  test "doc" do
    {:ok, file} = File.read("priv/test.doc")

    assert FormatParser.parse(file).format == :doc
    assert FormatParser.parse(file).nature == :document
  end

  test "odt" do
    {:ok, file} = File.read("priv/test.odt")

    assert FormatParser.parse(file).format == :odt
    assert FormatParser.parse(file).nature == :document
  end

  test "epub" do
    {:ok, file} = File.read("priv/test.epub")

    assert FormatParser.parse(file).format == :epub
    assert FormatParser.parse(file).nature == :document
  end
end
