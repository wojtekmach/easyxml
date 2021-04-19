defmodule EasyXMLTest do
  use ExUnit.Case
  doctest EasyXML

  test "greets the world" do
    encoded = """
    <?xml version="1.0" encoding="utf-8"?>\
    <points>\
    <point x="1" y="2"/>\
    <point x="3" y="4"/>\
    </points>\
    """

    decoded =
      {"points",
       [
         {"point", %{"x" => "1", "y" => "2"}, []},
         {"point", %{"x" => "3", "y" => "4"}, []}
       ]}

    assert EasyXML.parse!(encoded) == decoded
    assert EasyXML.dump_to_iodata(decoded) |> IO.iodata_to_binary() == encoded
  end
end
