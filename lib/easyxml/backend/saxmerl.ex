defmodule EasyXML.Backend.Saxmerl do
  @moduledoc """
  A backend based on `Saxmerl`.

  ## Examples

      iex> doc = EasyXML.parse!("<hello>world</hello>", backend: EasyXML.Backend.Saxmerl)
      iex> doc["/hello"]
      "world"

  """

  @behaviour EasyXML.Backend

  require Logger

  @impl true
  def parse!(xml, opts) do
    unless Code.ensure_loaded?(Saxmerl) do
      Logger.error("""
      Could not find saxmerl dependency.

      Please add it to your dependencies:

          {:saxmerl, "~> 0.1.0"}
      """)

      raise "missing saxmerl dependency"
    end

    _ = Application.ensure_all_started(:saxmerl)
    {:ok, xml} = Saxmerl.parse_string(xml, opts)
    %EasyXML.Doc{backend: __MODULE__, private: xml}
  end

  @impl true
  defdelegate xpath(doc, xpath), to: EasyXML.Backend.Xmerl

  @impl true
  defdelegate to_algebra(doc, opts), to: EasyXML.Backend.Xmerl

  @impl true
  defdelegate dump_to_iodata(doc), to: EasyXML.Backend.Xmerl
end
