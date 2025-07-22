defmodule FormatParser.DataTest do
  use ExUnit.Case

  test "route passed result" do
    assert FormatParser.Data.parse(%FormatParser.Data{}) == %FormatParser.Data{}
  end

  test "pqt" do
    {:ok, file} = File.read("priv/test.pqt")

    assert FormatParser.parse(file).format == :pqt
    assert FormatParser.parse(file).nature == :data
  end
end
