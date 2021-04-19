defmodule EasyXML.MixProject do
  use Mix.Project

  def project do
    [
      app: :easyxml,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :xmerl]
    ]
  end

  defp deps do
    []
  end
end
