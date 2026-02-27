defmodule FormatParser.Audio do
  alias __MODULE__

  @moduledoc """
  An Audio struct and functions.

  The Audio struct contains the fields format, sample_rate_hz, num_audio_channels, intrinsics and nature.

  ## Supported Formats

  | Format    | Sample Rate | Channels | Intrinsics |
  |-----------|:-----------:|:--------:|------------|
  | `:aiff`   |             | ✓        | num_frames, bits_per_sample |
  | `:wav`    | ✓           | ✓        | byte_rate, block_align, bits_per_sample |
  | `:vorbis` | ✓           | ✓        | vorbis_version |
  | `:opus`   | ✓           | ✓        | version, pre_skip, output_gain, mapping_family |
  | `:flac`   | ✓           | ✓        | |
  | `:oggflac` |            |          | |
  | `:mp3`    |             |          | |
  | `:aac`    |             |          | |
  | `:m4a`    |             |          | |
  | `:midi`   |             |          | format, num_tracks, time_division |

  """

  @typedoc """
  A struct representing a parsed audio file.

  ## Fields

    * `:format` - The audio format as an atom (e.g., `:wav`, `:mp3`, `:flac`)
    * `:sample_rate_hz` - The sample rate in Hz (e.g., 44100, 48000), if available
    * `:num_audio_channels` - The number of audio channels (e.g., 1 for mono, 2 for stereo)
    * `:nature` - Always `:audio` for audio files
    * `:intrinsics` - A map containing format-specific metadata

  """
  @type t :: %Audio{
          format: atom() | nil,
          sample_rate_hz: integer() | nil,
          num_audio_channels: integer() | nil,
          nature: :audio,
          intrinsics: map()
        }

  defstruct [
    :format,
    :sample_rate_hz,
    :num_audio_channels,
    nature: :audio,
    intrinsics: %{}
  ]

  @doc """
  Parses an audio file or result.

  - If given a tuple `{:error, file}` where `file` is a binary, attempts to parse the audio file.
  - If given a binary `file`, attempts to parse the audio file.
  - For any other input, returns the input as-is (passthrough for parser chain).

  ## Examples

      iex> {:ok, file} = File.read("priv/test.wav")
      iex> result = FormatParser.Audio.parse(file)
      iex> result.format
      :wav
      iex> result.sample_rate_hz
      48000

      iex> FormatParser.Audio.parse(%FormatParser.Image{})
      %FormatParser.Image{}

  """
  @spec parse({:error, binary()} | binary() | any()) :: any()
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
      <<_::binary-size(4), "ftypM4A ", _::binary>> -> parse_m4a(file)
      <<0xFF, 0xF1, _::binary>> -> parse_aac(file)
      <<"MThd", x::binary>> -> parse_midi(x)
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

  defp parse_ogg(<<_::binary-size(29), "fLaC", x::binary>>) do
    parse_ogg_flac(x)
  end

  defp parse_ogg(<<_::binary-size(29), "vorbis", x::binary>>) do
    parse_vorbis(x)
  end

  defp parse_ogg(<<_::binary-size(28), "OpusHead", x::binary>>) do
    parse_opus(x)
  end

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

  defp parse_aiff(
         <<_::size(56), "COMM", _::size(32), channels::size(16), frames::size(32),
           bits_per_sample::size(16), _sample_rate_components::size(80), _::binary>>
       ) do
    intrinsics = %{num_frames: frames, bits_per_sample: bits_per_sample}
    %Audio{format: :aiff, num_audio_channels: channels, intrinsics: intrinsics}
  end

  defp parse_aac(<<_::binary>>) do
    %Audio{format: :aac}
  end

  defp parse_ogg_flac(<<_::binary>>) do
    %Audio{format: :oggflac}
  end

  defp parse_m4a(<<_::binary>>) do
    %Audio{format: :m4a}
  end

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

  # MIDI file format
  # Header: MThd + length (4 bytes, always 6) + format (2 bytes) + num_tracks (2 bytes) + time_division (2 bytes)
  defp parse_midi(<<
         _length::big-integer-size(32),
         format::big-integer-size(16),
         num_tracks::big-integer-size(16),
         time_division::big-integer-size(16),
         _::binary
       >>) do
    intrinsics = %{
      format: format,
      num_tracks: num_tracks,
      time_division: time_division
    }

    %Audio{format: :midi, intrinsics: intrinsics}
  end

  defp parse_midi(<<_::binary>>) do
    %Audio{format: :midi}
  end
end
