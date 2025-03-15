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
      <<"RIFF", _::binary-size(4), "WAVE", x::binary>> -> parse_wav(x)
      <<"OggS", _::binary>> -> parse_ogg(file)
      <<"FORM", 0x00, x::binary>> -> parse_aiff(x)
      <<"fLaC", x::binary>> -> parse_flac(x)
      <<"ID3", x::binary>> -> parse_mp3(x)
      <<0xFF, 0xF1, _::binary>> -> parse_aac(file)
      _ -> {:error, file}
    end
  end

  @doc """
  Parses an MP3 file and returns an Audio struct with format set to :mp3.
  """
  defp parse_mp3(<<_::binary>>) do
    %Audio{format: :mp3}
  end

  @doc """
  Parses a FLAC file and returns an Audio struct with format set to :flac.
  Extracts the sample rate and number of audio channels from the file.
  """
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

  @doc """
  Parses an OGG file and determines if it is a Vorbis or Opus file.
  """
  defp parse_ogg(<<_::binary-size(29), "vorbis", x::binary>>), do: parse_vorbis(x)
  defp parse_ogg(<<_::binary-size(28), "OpusHead", x::binary>>), do: parse_opus(x)

  @doc """
  Parses a Vorbis file and returns an Audio struct with format set to :vorbis.
  Extracts the sample rate, number of audio channels, and Vorbis version from the file.
  """
  defp parse_vorbis(<<
         vorbis_version::size(32),
         channels::size(8),
         sample_rate_hz::little-integer-size(32),
         _::binary
       >>) do
    intrinsics = %{
      vorbis_version: vorbis_version
    }

    %Audio{
      format: :vorbis,
      sample_rate_hz: sample_rate_hz,
      num_audio_channels: channels,
      intrinsics: intrinsics
    }
  end

  @doc """
  Parses a WAV file and returns an Audio struct with format set to :wav.
  Extracts the sample rate, number of audio channels, byte rate, block align, and bits per sample from the file.
  """
  defp parse_wav(
         <<_::binary-size(10), channels::little-integer-size(16),
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

  @doc """
  Parses an AIFF file and returns an Audio struct with format set to :aiff.
  Extracts the number of audio channels, number of frames, and bits per sample from the file.
  """
  defp parse_aiff(
         <<_::size(56), "COMM", _::size(32), channels::size(16), frames::size(32),
           bits_per_sample::size(16), _sample_rate_components::size(80), _::binary>>
       ) do
    intrinsics = %{num_frames: frames, bits_per_sample: bits_per_sample}
    %Audio{format: :aiff, num_audio_channels: channels, intrinsics: intrinsics}
  end

  @doc """
  Parses an AAC file and returns an Audio struct with format set to :aac.
  """
  defp parse_aac(<<_::binary>>) do
    %Audio{format: :aac}
  end

  @doc """
  Parses an Opus file and returns an Audio struct with format set to :opus.
  Extracts the sample rate, number of audio channels, version, pre-skip, output gain, and mapping family from the file.
  """
  defp parse_opus(<<
         version::integer-size(8),
         channels::integer-size(8),
         pre_skip::little-integer-size(16),
         sample_rate_hz::little-integer-size(32),
         output_gain::little-integer-size(16),
         mapping_family::integer-size(8),
         _::binary
       >>) do
    intrinsics = %{
      version: version,
      pre_skip: pre_skip,
      output_gain: output_gain,
      mapping_family: mapping_family
    }

    %Audio{
      format: :opus,
      sample_rate_hz: sample_rate_hz,
      num_audio_channels: channels,
      intrinsics: intrinsics
    }
  end
end
