defmodule FormatParser.Image do
  @moduledoc """
  This module represents an Image file.

  It has the following attributes: `format`, `width_px`, `height_px`, `nature`
  """
  defstruct [:format, :width_px, :height_px, nature: :image, intrinsics: %{}]
end
