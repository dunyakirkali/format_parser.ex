defmodule FormatParser.AudioTest do
  use ExUnit.Case
  
  test "aiff" do
    {:ok, file} = File.read("priv/test.aiff")

    assert FormatParser.parse(file).format == :aiff
    assert FormatParser.parse(file).nature == :audio
    # assert FormatParser.parse(file).sample_rate_hz == 41_000
    assert FormatParser.parse(file).num_audio_channels == 2
  end
  
  test "wav" do
    {:ok, file} = File.read("priv/test.wav")

    assert FormatParser.parse(file).format == :wav
    assert FormatParser.parse(file).nature == :audio
    assert FormatParser.parse(file).sample_rate_hz == 48_000
    assert FormatParser.parse(file).num_audio_channels == 2
  end
  
  test "ogg" do
    {:ok, file} = File.read("priv/test.ogg")

    assert FormatParser.parse(file).format == :ogg
    assert FormatParser.parse(file).nature == :audio
    assert FormatParser.parse(file).sample_rate_hz == 44_100
    assert FormatParser.parse(file).num_audio_channels == 2
  end
  
  test "flac" do
    {:ok, file} = File.read("priv/test.flac")

    assert FormatParser.parse(file).format == :flac
    assert FormatParser.parse(file).nature == :audio
    assert FormatParser.parse(file).sample_rate_hz == 96_000
    assert FormatParser.parse(file).num_audio_channels == 1
  end
  
  test "mp3" do
    {:ok, file} = File.read("priv/test.mp3")

    assert FormatParser.parse(file).format == :mp3
    assert FormatParser.parse(file).nature == :audio
    # assert FormatParser.parse(file).sample_rate_hz == 48_000
    # assert FormatParser.parse(file).num_audio_channels == 2
  end
end
