defmodule FormatParser.Archive do
  alias __MODULE__

  @moduledoc """
  An Archive struct and functions.

  The Archive struct contains the fields format and nature.
  """
  @type t :: %__MODULE__{
          format: any(),
          nature: atom(),
          intrinsics: map()
        }
  defstruct [:format, nature: :archive, intrinsics: %{}]

  @iso_signature_offset 0x8001

  @doc """
  Parses the given input based on its type.

  - If the input is a tuple `{:error, file}` where `file` is a binary, it attempts to parse the file data.
  - If the input is a binary, it parses the file data.
  - For any other input, it returns the input as is.

  ## Examples

    iex> parse({:error, "file.txt"})
    # Parses the file data

    iex> parse("file.txt")
    # Parses the file data

    iex> parse(:ok)
    :ok

  """
  @spec parse({:error, binary()} | binary() | any()) :: any()
  def parse({:error, file}) when is_binary(file) do
    parse_archive(file)
  end

  def parse(file) when is_binary(file) do
    parse_archive(file)
  end

  def parse(result) do
    result
  end

  defp parse_archive(file) do
    case file do
      <<_::size(@iso_signature_offset * 8), "CD001", _rest::binary>> ->
        parse_iso(file)

      # ZIP archive - PK\x03\x04 magic bytes
      # Note: This must come after Document parser in the chain since DOCX, XLSX, etc. are also ZIP-based
      <<"PK", 0x03, 0x04, _rest::binary>> ->
        parse_zip(file)

      # RAR archive - RAR! magic bytes (RAR 1.5+)
      <<"Rar!", 0x1A, 0x07, _rest::binary>> ->
        parse_rar(file)

      # 7z archive
      <<0x37, 0x7A, 0xBC, 0xAF, 0x27, 0x1C, _rest::binary>> ->
        parse_7z(file)

      # GZIP archive
      <<0x1F, 0x8B, _rest::binary>> ->
        parse_gzip(file)

      # BZIP2 archive
      <<"BZ", 0x68, _rest::binary>> ->
        parse_bzip2(file)

      # XZ archive
      <<0xFD, "7zXZ", 0x00, _rest::binary>> ->
        parse_xz(file)

      # TAR archive (ustar format) - magic at offset 257
      _ ->
        parse_tar_or_unknown(file)
    end
  end

  defp parse_tar_or_unknown(file) do
    # TAR ustar magic is at offset 257
    case file do
      <<_::binary-size(257), "ustar", _rest::binary>> ->
        parse_tar(file)

      _ ->
        {:error, file}
    end
  end

  defp parse_iso(<<_::binary>>) do
    %Archive{format: :iso}
  end

  defp parse_zip(<<_::binary>>) do
    %Archive{format: :zip}
  end

  defp parse_rar(<<_::binary>>) do
    %Archive{format: :rar}
  end

  defp parse_7z(<<_::binary>>) do
    %Archive{format: :"7z"}
  end

  defp parse_gzip(<<_::binary>>) do
    %Archive{format: :gz}
  end

  defp parse_bzip2(<<_::binary>>) do
    %Archive{format: :bz2}
  end

  defp parse_xz(<<_::binary>>) do
    %Archive{format: :xz}
  end

  defp parse_tar(<<_::binary>>) do
    %Archive{format: :tar}
  end
end
