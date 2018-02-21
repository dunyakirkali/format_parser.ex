defmodule FormatParser.Video do
  @moduledoc """
  This module represents an Video file.

  It has the following attributes: `format`, `width_px`, `height_px`, `nature`
  """
  defstruct [:format, :width_px, :height_px, nature: :video]
end
