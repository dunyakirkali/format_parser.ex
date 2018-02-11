defmodule FormatParser do
  alias FormatParser.File

  def parse(file) do
    case file do
      <<255, 216, 255, x :: binary>> -> %File{nature: :image, format: :jpeg}
      <<73, 73, 42, 0, 16, 0, 0, 0, 67, 82, x :: binary>> -> %File{nature: :image, format: :cr2}
      <<73, 73, 42, 0, x :: binary>> -> %File{nature: :image, format: :tif}
      <<0, 0, 1, 0, x :: binary>> -> %File{nature: :image, format: :ico}
      <<123, 92, 114, 116, 102, 49, x :: binary>> -> %File{nature: :text, format: :rtf}
      <<66, 77, x :: binary>> ->  %File{nature: :image, format: :bmp}
      <<77, 77, 0, 42, x :: binary>> -> :tiff
      <<128, 42, 95, 215, x :: binary>> -> :cin
      true -> {:error, "Unknown"}
    end
  end
end
