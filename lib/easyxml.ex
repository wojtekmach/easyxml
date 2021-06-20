defmodule EasyXML do
  @external_resource "README.md"

  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @doc """
  Parses an XML string into a document.

  ## Options

    * `:backend` - a module implementing `EasyXML.Backend` behaviour, defaults
      to `EasyXML.Backend.Xmerl`.

  The remaining options are passed down to the backend.

  ## Examples

      doc = EasyXML.parse!("<hello>world</hello>")
      #=> #EasyXML.Doc[<hello>world</hello>]
      doc["hello"]
      #=> "world"

  """
  def parse!(xml, opts \\ []) do
    {backend, opts} = Keyword.pop(opts, :backend, EasyXML.Backend.Xmerl)
    backend.parse!(xml, opts)
  end

  @doc """
  Query the XML document.

  ## Examples

      doc = EasyXML.parse!(~s|<points><point x="1" y="2"/><point x="3" y="4"/></points>|)
      EasyXML.xpath(xml, "//point")
      #=> [#EasyXML.Doc[<point x="1" y="2"/>], #EasyXML.Doc[<point x="3" y="4"/>]]
      EasyXML.xpath(xml, "//point[1]/@x")
      #=> ["1"]

  """
  def xpath(doc_or_xml, xpath)

  def xpath(%EasyXML.Doc{} = doc, xpath) when is_binary(xpath) do
    doc.backend.xpath(doc, xpath)
  end

  def xpath(xml, xpath) when is_binary(xml) do
    xml |> parse!() |> xpath(xpath)
  end

  @doc """
  Dumps the XML document into an iodata.
  """
  def dump_to_iodata(%EasyXML.Doc{} = doc) do
    doc.backend.dump_to_iodata(doc)
  end
end
