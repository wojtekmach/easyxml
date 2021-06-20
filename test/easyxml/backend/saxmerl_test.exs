defmodule EasyXML.Backend.SaxmerlTest do
  use ExUnit.Case, async: true

  test "it works" do
    xml = """
    <?xml version="1.0" encoding="utf-8"?>\
    <doc>\
    <points>\
    <point x="1" y="2"/>\
    <point x="3" y="4"/>\
    <point x="5" y="6"/>\
    </points>\
    <strings>\
    <string>foo</string>\
    <string>bar</string>\
    </strings>\
    </doc>\
    """

    doc = EasyXML.parse!(xml, backend: EasyXML.Backend.Saxmerl)

    assert doc |> EasyXML.dump_to_iodata() |> IO.iodata_to_binary() == xml

    assert EasyXML.xpath(doc, "//point/@x") == ["1", "3", "5"]
    assert EasyXML.xpath(doc, "//point") |> Enum.map(& &1["@x"]) == ["1", "3", "5"]

    assert_raise RuntimeError, ~r|only works on single nodes with text content|, fn ->
      doc["//point[1]"]
    end

    assert EasyXML.xpath(doc, "//string/text()") == ["foo", "bar"]
    assert EasyXML.xpath(doc, "//string") |> Enum.map(& &1["."]) == ["foo", "bar"]
    assert doc["//string[1]"] == "foo"

    refute doc["bad"]
    refute doc["@bad"]
  end
end
