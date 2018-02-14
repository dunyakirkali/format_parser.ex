defmodule FormatParser do
  alias FormatParser.Image
  alias FormatParser.Video
  alias FormatParser.Document
  alias FormatParser.Audio

  def parse(file) do
    case file do
      <<0x89, "PNG", 0x0D, 0x0A, 0x1A, 0x0A, x :: binary>> -> parse_png(x)
      <<"BM", x :: binary>> -> parse_bmp(x)
      <<"GIF89a", x :: binary>> -> parse_gif(x)
      <<"RIFF", x :: binary>> -> parse_wav(x)
      <<"OggS", x :: binary>> -> parse_ogg(x)
      <<"FORM", 0x00, x :: binary>> -> parse_aiff(x)
      <<"fLaC", x :: binary>> -> parse_flac(x)
      <<"FLV", 0x01, x :: binary>> -> parse_flv(x)
      <<"GIF87a", x :: binary>> -> parse_gif(x)
      <<0xFF, 0xD8, 0xFF, x :: binary>> -> parse_jpeg(x)
      <<0x49, 0x49, 0x2A, 0x00, 0x10, 0x00, 0x00, 0x00, 0x43, 0x52, x :: binary>> -> %Image{format: :cr2}
      <<0x49, 0x49, 0x2A, 0x00, x :: binary>> -> %Image{format: :tif}
      <<0x00, 0x00, 0x01, 0x00, x :: binary>> -> %Image{format: :ico}
      <<0x7B, 0x5C, 0x72, 0x74, 0x66, 0x31, x :: binary>> -> %Document{format: :rtf}
      <<0x4D, 0x4D, 0x00, 0x2A, x :: binary>> -> :tiff
      <<0x80, 0x2A, 0x5F, 0xD7, x :: binary>> -> :cin
      
      true -> {:error, "Unknown"}
    end
  end
  
  def parse_flac(<<x:: binary>>) do
    %Audio{format: :flac}
  end
  
  def parse_ogg(<<x:: binary>>) do
    %Audio{format: :ogg}
  end
  
  def parse_wav(<<_ :: size(144), channels :: little-integer-size(16), sample_rate_hz :: little-integer-size(32), x :: binary>>) do
    %Audio{format: :wav, sample_rate_hz: sample_rate_hz, num_audio_channels: channels}
  end
  
  def parse_aiff(<<_ :: size(56), "COMM", _ :: size(96), sample_rate_hz :: size(80), x :: binary>>) do
    %Audio{format: :aiff, sample_rate_hz: sample_rate_hz}
  end
  
  def parse_flv(x) do
    %Video{format: :flv}
  end
  
  defp parse_gif(<< width :: little-integer-size(16), height :: little-integer-size(16), _x :: binary>>) do
    %Image{format: :gif, width_px: width, height_px: height}
  end

  defp parse_jpeg(binary) do
    %Image{format: :jpg}
  end

  defp parse_bmp(<< _header :: size(128), width :: little-integer-size(32), height :: little-integer-size(32), _x :: binary>>) do
    %Image{format: :bmp, width_px: width, height_px: height}
  end

  defp parse_png(<< _length :: size(32), "IHDR", width :: size(32), height :: size(32), _x :: binary>>) do
    %Image{format: :png, width_px: width, height_px: height}
  end
end
