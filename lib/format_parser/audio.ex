defmodule FormatParser.Audio do
  alias __MODULE__

  @moduledoc """
  An Audio struct and functions.

  The Audio struct contains the fields format, sample_rate_hz, num_audio_channels, intrinsics and nature.
  """

  defstruct [
    :format,
    :sample_rate_hz,
    :num_audio_channels,
    nature: :audio,
    intrinsics: %{}
  ]

  @doc """
  Parses a file and extracts some information from it.

  Takes a `binary file` as argument.

  Returns a struct which contains all information that has been extracted from the file if the file is recognized.

  Returns the following tuple if file not recognized: `{:error, file}`.

  """
  def parse({:error, file}) when is_binary(file) do
    parse_audio(file)
  end

  def parse(file) when is_binary(file) do
    parse_audio(file)
  end

  def parse(result) do
    result
  end

  defp parse_audio(file) do
    case file do
      <<"RIFF", x::binary>> -> parse_wav(x)
      <<"OggS", x::binary>> -> parse_ogg(x)
      <<"FORM", 0x00, x::binary>> -> parse_aiff(x)
      <<"fLaC", x::binary>> -> parse_flac(x)
      <<"ID3", x::binary>> -> parse_mp3(x)
      _ -> {:error, file}
    end
  end

  defp parse_mp3(<<_::binary>>) do
    %Audio{format: :mp3}
  end

  defp parse_flac(
         <<_::size(112), sample_rate_hz::size(20), num_audio_channels::size(3), _::size(5),
           _::size(36), _::binary>>
       ) do
    %Audio{
      format: :flac,
      sample_rate_hz: sample_rate_hz,
      num_audio_channels: num_audio_channels
    }
  end

  defp parse_ogg(
         <<_::size(280), channels::little-integer-size(8),
           sample_rate_hz::little-integer-size(32), _::binary>>
       ) do
    %Audio{
      format: :ogg,
      sample_rate_hz: sample_rate_hz,
      num_audio_channels: channels
    }
  end

  defp parse_wav(
         <<_::size(144), channels::little-integer-size(16),
           sample_rate_hz::little-integer-size(32), byte_rate::little-integer-size(32),
           block_align::little-integer-size(16), bits_per_sample::little-integer-size(16),
           _::binary>>
       ) do
    intrinsics = %{
      byte_rate: byte_rate,
      block_align: block_align,
      bits_per_sample: bits_per_sample
    }

    %Audio{
      format: :wav,
      sample_rate_hz: sample_rate_hz,
      num_audio_channels: channels,
      intrinsics: intrinsics
    }
  end

  defp parse_aiff(
         <<_::size(56), "COMM", _::size(32), channels::size(16), frames::size(32),
           bits_per_sample::size(16), _sample_rate_components::size(80), _::binary>>
       ) do
    intrinsics = %{num_frames: frames, bits_per_sample: bits_per_sample}
    %Audio{format: :aiff, num_audio_channels: channels, intrinsics: intrinsics}
  end
end
