defmodule EasyXML.Doc do
  defstruct [:backend, :private]

  @type t() :: %EasyXML.Doc{backend: module()}

  @moduledoc """
  The XML document.
  """

  @doc """
  Fetch the text specified by the given `xpath`.

  ## Examples

      iex> doc = EasyXML.parse!("<hello>world</hello>")
      iex> doc["hello"]
      {:ok, "world"}
  """
  def fetch(doc, xpath)

  def fetch(doc, "@" <> key) do
    case EasyXML.xpath(doc, "@#{key}") do
      [value] when is_binary(value) ->
        {:ok, value}

      [] ->
        :error
    end
  end

  def fetch(doc, path) do
    case EasyXML.xpath(doc, "#{path}/text()") do
      [value] when is_binary(value) ->
        {:ok, value}

      [] ->
        case EasyXML.xpath(doc, path) do
          [value] when is_binary(value) ->
            {:ok, value}

          [] ->
            :error

          doc ->
            raise "doc[path] only works on single nodes with text content, use EasyXML.xpath/2 for other cases. Got: #{inspect(doc)}"
        end
    end
  end

  defimpl Inspect do
    def inspect(doc, opts) do
      Inspect.Algebra.concat([
        "#EasyXML.Doc[",
        doc.backend.to_algebra(doc, opts),
        "]"
      ])
    end
  end
end
