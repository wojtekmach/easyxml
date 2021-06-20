defmodule EasyXML.Backend do
  @callback parse!(xml :: String.t(), opts :: keyword()) :: %EasyXML.Doc{}

  @callback xpath(%EasyXML.Doc{}, path :: String.t()) :: [term()]

  @callback to_algebra(%EasyXML.Doc{}, opts :: keyword()) :: Inspect.Algebra.t()

  @callback dump_to_iodata(%EasyXML.Doc{}) :: iodata()
end
