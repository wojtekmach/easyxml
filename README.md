# EasyXML

[Docs](http://wojtekmach.pl/docs/easyxml)

<!-- MDOC !-->

An easy-to-use XML library for Elixir.

## Features

  * Convenient access via the `doc[path]` notation

  * Support for multiple backends

## Usage

The easiest way to use EasyXML is with `Mix.install/2` (requires Elixir v1.12+):

```elixir
Mix.install([
  {:easyxml, "~> 0.1.0-dev", github: "wojtekmach/easyxml", branch: "main"}
])

xml =
  """
  <points>
    <point x="1" y="2"/>
    <point x="3" y="4"/>
  </points>
  """

doc = EasyXML.parse!(xml)

EasyXML.xpath(doc, "//point/@x")
#=> ["1", "3"]

EasyXML.xpath(doc, "//point") |> Enum.map(& &1["@x"])
#=> ["1", "3"]

doc["//point[1]/@x"]
#=> "1"
```

<!-- MDOC !-->

## License

Copyright (c) 2021 Wojtek Mach

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
