defmodule FormatParser.Archive do
  alias __MODULE__

  @moduledoc """
  An Archive struct and functions.

  The Archive struct contains the fields format, nature, and intrinsics.

  ## Supported Formats

  - `:zip` - ZIP archive
  - `:rar` - RAR archive (1.5+)
  - `:"7z"` - 7-Zip archive
  - `:gz` - GZIP compressed file
  - `:bz2` - BZIP2 compressed file
  - `:xz` - XZ compressed file
  - `:tar` - TAR archive (ustar format)
  - `:iso` - ISO 9660 disc image
  - `:zstd` - Zstandard compressed file
  """

  @typedoc """
  The Archive struct.

  ## Fields

  - `:format` - The detected archive format (e.g., `:zip`, `:rar`, `:gz`)
  - `:nature` - Always `:archive` for this struct
  - `:intrinsics` - Additional format-specific metadata (currently unused)
  """
  @type t :: %__MODULE__{
          format: atom() | nil,
          nature: :archive,
          intrinsics: map()
        }
  defstruct [:format, nature: :archive, intrinsics: %{}]

  @iso_signature_offset 0x8001

  @doc """
  Parses an archive file and returns an Archive struct if recognized.

  This function attempts to detect the archive format by examining magic bytes
  at specific offsets in the binary data.

  ## Arguments

  - `input` - Can be one of:
    - `{:error, binary}` - A tuple containing binary file data (used in parser chain)
    - `binary` - Raw binary file data
    - `any` - Any other value is returned as-is (pass-through for parser chain)

  ## Returns

  - `%Archive{}` - If the file is a recognized archive format
  - `{:error, binary}` - If the file is not recognized as an archive
  - The input unchanged if it's not a binary or error tuple

  ## Examples

      iex> {:ok, file} = File.read("archive.zip")
      iex> FormatParser.Archive.parse(file)
      %FormatParser.Archive{format: :zip, nature: :archive, intrinsics: %{}}

      iex> FormatParser.Archive.parse({:error, zip_binary})
      %FormatParser.Archive{format: :zip, nature: :archive, intrinsics: %{}}

      iex> FormatParser.Archive.parse(%FormatParser.Image{})
      %FormatParser.Image{}

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

      # ZSTD archive
      <<0x28, 0xB5, 0x2F, 0xFD, _rest::binary>> ->
        parse_zstd(file)

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

  defp parse_zstd(<<_::binary>>) do
    %Archive{format: :zstd}
  end
end
