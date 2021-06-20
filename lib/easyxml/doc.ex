defmodule EasyXML.Doc do
  defstruct [:doc, :backend]

  defimpl Inspect do
    def inspect(doc, opts) do
      Inspect.Algebra.concat([
        "#EasyXML.Doc[",
        doc.backend.to_algebra(doc, opts),
        "]"
      ])
    end
  end

  @doc false
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
end
