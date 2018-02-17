defmodule FormatParser.Audio do
  @moduledoc """
  This module represents an Audio file.

  It has the following attributes: :format, :sample_rate_hz, :num_audio_channels, :nature
  """
  defstruct [:format, :sample_rate_hz, :num_audio_channels, nature: :audio]
end
