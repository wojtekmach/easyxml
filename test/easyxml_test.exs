defmodule EasyXMLTest do
  use ExUnit.Case, async: true
  doctest EasyXML

  test "it works" do
    xml = """
    <?xml version="1.0" encoding="utf-8"?>\
    <points>\
    <point x="1" y="2"/>\
    <point x="3" y="4"/>\
    <point x="5" y="6"/>\
    </points>\
    """

    node = EasyXML.parse!(xml)
    IO.inspect(node)
    assert node |> EasyXML.dump_to_iodata() |> IO.iodata_to_binary() == xml
    assert EasyXML.xpath(node, "//point") |> Enum.map(& &1["@x"]) == ["1", "3", "5"]
    refute node["bad"]
    refute node["@bad"]
  end
end
