defmodule FormatParser.ArchiveTest do
  use ExUnit.Case

  test "parse passed error" do
    {:ok, file} = File.read("priv/test.iso")

    assert FormatParser.Archive.parse({:error, file}).format == :iso
  end

  test "parse file" do
    {:ok, file} = File.read("priv/test.iso")

    assert FormatParser.Archive.parse(file).format == :iso
  end

  test "route passed result" do
    assert FormatParser.Archive.parse(%FormatParser.Archive{}) == %FormatParser.Archive{}
  end

  test "iso" do
    {:ok, file} = File.read("priv/test.iso")

    assert FormatParser.parse(file).format == :iso
    assert FormatParser.parse(file).nature == :archive
  end

  test "zip" do
    {:ok, file} = File.read("priv/test.zip")

    assert FormatParser.parse(file).format == :zip
    assert FormatParser.parse(file).nature == :archive
  end

  test "gzip" do
    {:ok, file} = File.read("priv/test.gz")

    assert FormatParser.parse(file).format == :gz
    assert FormatParser.parse(file).nature == :archive
  end

  test "tar" do
    {:ok, file} = File.read("priv/test.tar")

    assert FormatParser.parse(file).format == :tar
    assert FormatParser.parse(file).nature == :archive
  end
end
