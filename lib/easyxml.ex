defmodule EasyXML do
  def parse!(binary, opts \\ []) do
    xml = normalize(binary)
    decode(xml, opts)
  end

  @doc false
  def normalize(binary) do
    data = :erlang.binary_to_list(binary)
    {doc, _} = :xmerl_scan.string(data, space: :normalize, comments: false)
    [clean] = :xmerl_lib.remove_whitespace([doc])
    clean
  end

  require Record

  for {name, fields} <- Record.extract_all(from_lib: "xmerl/include/xmerl.hrl") do
    Record.defrecordp(name, fields)
  end

  defp decode(xmlAttribute(value: value), _opts) do
    List.to_string(value)
  end

  defp decode(xmlText(value: value), _opts) do
    List.to_string(value)
  end

  defp decode(doc, opts) do
    doc = :xmerl_lib.simplify_element(doc)
    keys = Keyword.get(opts, :keys, :binaries)
    do_xml_decode(doc, keys)
  end

  def xpath(binary, path, opts \\ []) when is_binary(binary) and is_binary(path) do
    doc = normalize(binary)

    :xmerl_xpath.string(String.to_charlist(path), doc)
    |> Enum.map(&decode(&1, opts))
  end

  def dump_to_iodata(data, opts \\ []) do
    keys = Keyword.get(opts, :keys, :binaries)

    prolog = xmlAttribute(name: :prolog, value: "<?xml version=\"1.0\" encoding=\"utf-8\"?>")
    xml = do_xml_encode(data, keys)
    :xmerl.export_simple([xml], :xmerl_xml, [prolog])
  end

  defp do_xml_encode({tag, attrs, content}, keys) do
    {encode_key(tag, keys), xml_attrs_encode(attrs, keys), do_xml_encode(content, keys)}
  end

  defp do_xml_encode({tag, attrs}, keys) when is_map(attrs) do
    {encode_key(tag, keys), xml_attrs_encode(attrs, keys), []}
  end

  defp do_xml_encode({tag, content}, keys) do
    {encode_key(tag, keys), [], do_xml_encode(content, keys)}
  end

  defp do_xml_encode(list, keys) when is_list(list) do
    Enum.map(list, &do_xml_encode(&1, keys))
  end

  defp do_xml_encode(binary, _keys) when is_binary(binary) do
    [:erlang.binary_to_list(binary)]
  end

  defp do_xml_decode({tag, [], content}, keys) do
    {decode_key(tag, keys), do_xml_decode(content, keys)}
  end

  defp do_xml_decode({tag, attrs, content}, keys) do
    {decode_key(tag, keys), xml_attrs_decode(attrs, keys), do_xml_decode(content, keys)}
  end

  defp do_xml_decode([charlist], _keys) when is_list(charlist) do
    List.to_string(charlist)
  end

  defp do_xml_decode(list, keys) when is_list(list) do
    for item <- list do
      if is_list(item) do
        List.to_string(item)
      else
        do_xml_decode(item, keys)
      end
    end
  end

  def xml_attrs_encode(attrs, keys) when is_map(attrs) do
    for {name, value} <- attrs do
      {encode_key(name, keys), :erlang.binary_to_list(value)}
    end
  end

  defp xml_attrs_decode(attrs, keys) do
    for {name, value} <- attrs, into: %{} do
      {decode_key(name, keys), List.to_string(value)}
    end
  end

  defp encode_key(key, :atoms), do: key
  defp encode_key(key, :binaries), do: String.to_atom(key)

  defp decode_key(key, :atoms), do: key
  defp decode_key(key, :binaries), do: Atom.to_string(key)
end
