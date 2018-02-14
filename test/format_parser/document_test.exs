defmodule FormatParser.DocumentTest do
  use ExUnit.Case
  
  test "rtf" do
    {:ok, file} = File.read("priv/test.rtf")

    assert FormatParser.parse(file).format == :rtf
    assert FormatParser.parse(file).nature == :document
  end
end
