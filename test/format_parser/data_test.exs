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

  test "sqlite3" do
    {:ok, file} = File.read("priv/test.sqlite3")

    assert FormatParser.parse(file).format == :sqlite3
    assert FormatParser.parse(file).nature == :data
  end

  test "duckdb" do
    {:ok, file} = File.read("priv/test.duckdb")

    assert FormatParser.parse(file).format == :duckdb
    assert FormatParser.parse(file).nature == :data
  end

  test "arrow" do
    {:ok, file} = File.read("priv/test.arrow")

    assert FormatParser.parse(file).format == :arrow
    assert FormatParser.parse(file).nature == :data
  end

  test "feather v1" do
    {:ok, file} = File.read("priv/test_v1.feather")

    assert FormatParser.parse(file).format == :feather
    assert FormatParser.parse(file).nature == :data
  end
end
