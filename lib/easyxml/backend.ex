defmodule EasyXML.Backend do
  @moduledoc """
  Specification for the XML backends.
  """

  @callback parse!(xml :: String.t(), opts :: keyword()) :: EasyXML.Doc.t()

  @callback xpath(doc :: EasyXML.Doc.t(), xpath :: String.t()) :: [term()]

  @callback to_algebra(doc :: EasyXML.Doc.t(), opts :: keyword()) :: Inspect.Algebra.t()

  @callback dump_to_iodata(doc :: EasyXML.Doc.t()) :: iodata()
end
