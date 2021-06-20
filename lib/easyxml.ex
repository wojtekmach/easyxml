defmodule EasyXML do
  def parse!(xml, opts \\ []) do
    {backend, opts} = Keyword.pop(opts, :backend, EasyXML.Backend.Xmerl)
    backend.parse!(xml, opts)
  end

  def xpath(doc_or_xml, path)

  def xpath(%EasyXML.Doc{} = doc, path) when is_binary(path) do
    doc.backend.xpath(doc, path)
  end

  def xpath(xml, path) when is_binary(xml) do
    xml |> parse!() |> xpath(path)
  end

  def to_algebra(%EasyXML.Doc{} = doc, opts) do
    doc.backend.to_algebra(doc, opts)
  end

  def dump_to_iodata(%EasyXML.Doc{} = doc) do
    doc.backend.dump_to_iodata(doc)
  end
end
