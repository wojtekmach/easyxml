defmodule EasyXML.MixProject do
  use Mix.Project

  def project do
    [
      app: :easyxml,
      version: "0.1.0-dev",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      xref: xref()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :xmerl]
    ]
  end

  defp deps do
    [
      {:saxmerl, "~> 0.1.0", optional: true},
      {:ex_doc, ">= 0.0.0", only: :docs}
    ]
  end

  defp docs do
    [
      main: "EasyXML",
      source_url: "https://github.com/wojtekmach/easyxml",
      source_ref: "main"
    ]
  end

  defp xref do
    [
      xref: [
        exclude: [
          Saxmerl
        ]
      ]
    ]
  end
end
