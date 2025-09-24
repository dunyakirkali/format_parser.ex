defmodule FormatParser.ArchiveTest do
  use ExUnit.Case

  test "route passed result" do
    assert FormatParser.Archive.parse(%FormatParser.Archive{}) == %FormatParser.Archive{}
  end

  test "iso" do
    {:ok, file} = File.read("priv/test.iso")

    assert FormatParser.parse(file).format == :iso
    assert FormatParser.parse(file).nature == :archive
  end
end
