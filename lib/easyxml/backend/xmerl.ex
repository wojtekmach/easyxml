defmodule EasyXML.Backend.Xmerl do
  @moduledoc """
  A backend based on `:xmerl`.
  """

  @behaviour EasyXML.Backend

  @impl true
  def parse!(xml, opts \\ []) do
    xml = :erlang.binary_to_list(xml)
    # TODO: fix encoding
    opts = Keyword.merge([space: :normalize, comments: false, encoding: :latin1], opts)
    {doc, rest} = :xmerl_scan.string(xml, opts)

    if rest != '' do
      raise "trailing content: #{rest}"
    end

    [doc] = :xmerl_lib.remove_whitespace([doc])
    %EasyXML.Doc{doc: doc, backend: __MODULE__}
  end

  require Record

  for {name, fields} <- Record.extract_all(from_lib: "xmerl/include/xmerl.hrl") do
    Record.defrecordp(name, fields)
  end

  @impl true
  def xpath(%EasyXML.Doc{} = doc, path) when is_binary(path) do
    for node <- :xmerl_xpath.string(String.to_charlist(path), doc.doc) do
      case node do
        binary when is_binary(binary) ->
          binary

        xmlAttribute(value: value) ->
          List.to_string(value)

        xmlText(value: value) ->
          List.to_string(value)

        xmlElement() = element ->
          %EasyXML.Doc{doc: element, backend: doc.backend}
      end
    end
  end

  @impl true
  def dump_to_iodata(%EasyXML.Doc{doc: xmlElement() = doc}) do
    prolog = xmlAttribute(name: :prolog, value: "<?xml version=\"1.0\" encoding=\"utf-8\"?>")
    :xmerl.export_simple([doc], :xmerl_xml, [prolog])
  end

  import Inspect.Algebra

  @impl true
  def to_algebra(%EasyXML.Doc{doc: doc}, opts) do
    opts = %{opts | syntax_colors: Keyword.put_new(opts.syntax_colors, :tag, :black)}
    to_algebra(doc, opts)
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
