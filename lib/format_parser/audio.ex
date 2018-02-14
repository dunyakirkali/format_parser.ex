defmodule FormatParser.Audio do
  defstruct [:format, :sample_rate_hz, :num_audio_channels, nature: :audio]
end
