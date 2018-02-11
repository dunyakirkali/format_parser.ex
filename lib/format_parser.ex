defmodule FormatParser do
  alias FormatParser.Image

  def parse(file) do
    case file do
      <<255, 216, 255, x :: binary>> -> parse_jpeg(x)
      <<73, 73, 42, 0, 16, 0, 0, 0, 67, 82, x :: binary>> -> %Image{nature: :image, format: :cr2}
      <<73, 73, 42, 0, x :: binary>> -> %Image{nature: :image, format: :tif}
      <<0, 0, 1, 0, x :: binary>> -> %Image{nature: :image, format: :ico}
      <<123, 92, 114, 116, 102, 49, x :: binary>> -> %Image{nature: :document, format: :rtf}
      <<66, 77, x :: binary>> -> parse_bmp(x)
      <<77, 77, 0, 42, x :: binary>> -> :tiff
      <<128, 42, 95, 215, x :: binary>> -> :cin
      <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, x :: binary>> -> parse_png(x)
      true -> {:error, "Unknown"}
    end
  end

  defp parse_jpeg(binary) do
    %Image{nature: :image, format: :jpg, width_px: 0, height_px: 0, orientation: :top_left}
  end

  defp parse_bmp(binary) do
    %Image{nature: :image, format: :bmp, width_px: 0, height_px: 0, orientation: :top_left}
  end

  defp parse_png(<< _length :: size(32), "IHDR", width :: size(32), height :: size(32), bit_depth, color_type, compression_method, filter_method, interlace_method, _crc :: size(32), chunks :: binary>>) do
    %Image{nature: :image, format: :png, width_px: width, height_px: height, orientation: nil}
  end
end
