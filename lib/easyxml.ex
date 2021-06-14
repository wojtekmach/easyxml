defmodule EasyXML.Node do
  defstruct [:node]

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(node, _opts) do
      doc = EasyXML.to_algebra(node)
      concat(["#EasyXML.Node[", doc, "]"])
    end
  end

  @doc false
  def fetch(node, "@" <> key) do
    case EasyXML.xpath(node, "@#{key}") do
      [value] when is_binary(value) ->
        {:ok, value}

      [] ->
        :error
    end
  end

  def fetch(node, key) do
    case EasyXML.xpath(node, "#{key}/text()") do
      [value] when is_binary(value) ->
        {:ok, value}

      [] ->
        case EasyXML.xpath(node, key) do
          [value] when is_binary(value) ->
            {:ok, value}

          [] ->
            nil

          nodes ->
            raise "node[#{inspect(key)}] only works on single nodes with text, use EasyXML.xpath/2 for other cases. Got: #{inspect(nodes)}"
        end
    end
  end
end

defmodule EasyXML do
  def parse!(xml) do
    xml = :erlang.binary_to_list(xml)
    # TODO: fix encoding
    {node, rest} = :xmerl_scan.string(xml, space: :normalize, comments: false, encoding: :latin1)

    if rest != '' do
      raise "trailing content: #{rest}"
    end

    [node] = :xmerl_lib.remove_whitespace([node])
    %EasyXML.Node{node: node}
  end

  require Record

  for {name, fields} <- Record.extract_all(from_lib: "xmerl/include/xmerl.hrl") do
    Record.defrecordp(name, fields)
  end

  def xpath(xml, path) when is_binary(xml) and is_binary(path) do
    xpath(parse!(xml), path)
  end

  def xpath(%EasyXML.Node{} = node, path) when is_binary(path) do
    for node <- :xmerl_xpath.string(String.to_charlist(path), node.node) do
      case node do
        binary when is_binary(binary) ->
          binary

        xmlAttribute(value: value) ->
          List.to_string(value)

        xmlText(value: value) ->
          List.to_string(value)

        xmlElement() = element ->
          %EasyXML.Node{node: element}
      end
    end
  end

  def dump_to_iodata(%EasyXML.Node{node: xmlElement() = node}) do
    prolog = xmlAttribute(name: :prolog, value: "<?xml version=\"1.0\" encoding=\"utf-8\"?>")
    :xmerl.export_simple([node], :xmerl_xml, [prolog])
  end

  def to_algebra(%EasyXML.Node{node: xmlElement() = element}) do
    doc = :xmerl.export_simple([element], :xmerl_xml, [])
    "<?xml version=\"1.0\"?>" <> rest = IO.iodata_to_binary(doc)
    rest
  end

  def to_algebra(%EasyXML.Node{node: xmlAttribute(value: value)}) do
    List.to_string(value)
  end
end
