defmodule FormatParser.Audio do
  @moduledoc """
  This module represents an Audio file.
  
  An audio file has the following attributes: `format`, `sample_rate_hz`, `num_audio_channels`, `nature`
  
  It can also contain one or many of the following attributes as `intrinsics`: `num_frames`, `bits_per_sample`
  """
  defstruct [:format, :sample_rate_hz, :num_audio_channels, nature: :audio, intrinsics: %{}]
end
