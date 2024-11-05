# Issues

**Project: Fetch Top N most recent issues in any github repo**

## Build

To build this application locally, simply clone the repo, navigate to the issues folder from your terminal, and execute the following commands

```zsh
$ mix deps.get
$ mix escript.build
```

Example Usage:
```elixir
$ ./issues grpc grpc 7 # usage: issues <user> <project> [ count | 4 ]

13:39:57.229 [info] Fetching grpc's project grpc

13:39:57.866 [info] Got response: status code=200
numbe | created_at           | title                                                              
------+----------------------+--------------------------------------------------------------------
38060 | 2024-11-05T02:49:27Z | [StatsPlugin] Use lock-free list for global stats plugins list     
38061 | 2024-11-05T06:42:01Z | [export] Internal protobuf config cleanup                          
38062 | 2024-11-05T18:06:26Z | Support for `host_rewrite_literal` in gRPC xDS Clients             
38063 | 2024-11-05T18:13:46Z | [CI] Updated RBE Windows Image (MSVC 2022)                         
38064 | 2024-11-05T18:18:36Z | custom user-agent can't override default                           
38065 | 2024-11-05T19:12:18Z | [http-proxy] Add a log message sampling HTTP proxy connect failures
38066 | 2024-11-05T19:13:13Z | [Deps] Updated protobuf-v29
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `issues` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:issues, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/issues>.

