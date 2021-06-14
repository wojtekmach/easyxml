defmodule EasyXML.Doc do
  defstruct [:node]

  defimpl Inspect do
    def inspect(node, opts) do
      EasyXML.to_algebra(node, opts)
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
            :error

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
    %EasyXML.Doc{node: node}
  end

  require Record

  for {name, fields} <- Record.extract_all(from_lib: "xmerl/include/xmerl.hrl") do
    Record.defrecordp(name, fields)
  end

  def xpath(xml, path) when is_binary(xml) and is_binary(path) do
    xpath(parse!(xml), path)
  end

  def xpath(%EasyXML.Doc{} = node, path) when is_binary(path) do
    for node <- :xmerl_xpath.string(String.to_charlist(path), node.node) do
      case node do
        binary when is_binary(binary) ->
          binary

        xmlAttribute(value: value) ->
          List.to_string(value)

        xmlText(value: value) ->
          List.to_string(value)

        xmlElement() = element ->
          %EasyXML.Doc{node: element}
      end
    end
  end

  def dump_to_iodata(%EasyXML.Doc{node: xmlElement() = node}) do
    prolog = xmlAttribute(name: :prolog, value: "<?xml version=\"1.0\" encoding=\"utf-8\"?>")
    :xmerl.export_simple([node], :xmerl_xml, [prolog])
  end

  import Inspect.Algebra

  def to_algebra(%EasyXML.Doc{node: node}, opts) do
    opts = %{opts | syntax_colors: Keyword.put_new(opts.syntax_colors, :tag, :black)}

    concat([
      "#EasyXML.Doc[",
      to_algebra(node, opts),
      "]"
    ])
  end

  def to_algebra(xmlElement(content: []) = element, opts) do
    open_tag(element, opts, true)
  end

  def to_algebra(xmlElement(content: [xmlText(value: value)]) = element, opts) do
    concat([
      open_tag(element, opts),
      color(List.to_string(value), :string, opts),
      close_tag(element, opts)
    ])
  end

  def to_algebra(xmlElement(content: content) = element, opts) do
    container_doc(
      open_tag(element, opts),
      content,
      close_tag(element, opts),
      opts,
      &to_algebra/2,
      break: :strict,
      separator: ""
    )
  end

  def to_algebra(xmlText(value: value), opts) do
    List.to_string(value)
    |> color(:string, opts)
  end

  def to_algebra(xmlAttribute(value: value), opts) do
    List.to_string(value)
    |> color(:string, opts)
  end

  def to_algebra(other, _opts) do
    raise inspect(other)
  end

  defp open_tag(xmlElement(name: name, attributes: attributes), opts, empty? \\ false) do
    attributes =
      for xmlAttribute(name: name, value: value) <- attributes do
        concat([tag(" #{name}=", opts), color("\"#{value}\"", :string, opts)])
      end
      |> concat()

    if empty? do
      concat([tag("<#{name}", opts), attributes, tag("/>", opts)])
    else
      concat([tag("<#{name}", opts), attributes, tag(">", opts)])
    end
  end

  defp close_tag(xmlElement(name: name), opts) do
    color("</#{name}>", :tag, opts)
  end

  defp tag(doc, opts) do
    color(doc, :tag, opts)
  end
end
