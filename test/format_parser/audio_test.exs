defmodule FormatParser.AudioTest do
  use ExUnit.Case

  test "parse passed error" do
    {:ok, file} = File.read("priv/test.aiff")

    assert FormatParser.Audio.parse({:error, file}).format == :aiff
  end

  test "parse file" do
    {:ok, file} = File.read("priv/test.aiff")

    assert FormatParser.Audio.parse(file).format == :aiff
  end

  test "route passed result" do
    assert FormatParser.Document.parse(%FormatParser.Video{}) == %FormatParser.Video{}
  end

  test "aiff" do
    {:ok, file} = File.read("priv/test.aiff")

    assert FormatParser.parse(file).format == :aiff
    assert FormatParser.parse(file).nature == :audio
    assert FormatParser.parse(file).num_audio_channels == 2
    assert FormatParser.parse(file).intrinsics == %{num_frames: 46433, bits_per_sample: 16}
  end

  test "wav" do
    {:ok, file} = File.read("priv/test.wav")

    assert FormatParser.parse(file).format == :wav
    assert FormatParser.parse(file).nature == :audio
    assert FormatParser.parse(file).sample_rate_hz == 48_000
    assert FormatParser.parse(file).num_audio_channels == 2

    assert FormatParser.parse(file).intrinsics == %{
             byte_rate: 192_000,
             block_align: 4,
             bits_per_sample: 16
           }
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
  end
end
