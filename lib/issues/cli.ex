defmodule Issues.CLI do
  @default_count 4
  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table of the last _n_ issues in a github project.
  """

  import Issues.TableFormatter, only: [print_table_for_columns: 2]

  @doc """
  Run the CLI with the given arguments.

  ## Parameters
    - argv: List of command line arguments.

  ## Examples

      iex> Issues.CLI.run(["elixir-lang", "elixir", "5"])
      :ok
  """
  @spec main([String.t()]) :: :ok
  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  Parse the command line arguments.

  `argv` can be -h or --help, which returns :help.
  Otherwise it is a github user name, project name, and (optionally)
  the number of entries to format.
  Return a tuple of `{ user, project, count }`, or `:help` if help was given.

  ## Parameters
    - argv: List of command line arguments.

  ## Examples

      iex> Issues.CLI.parse_args(["elixir-lang", "elixir", "5"])
      {"elixir-lang", "elixir", 5}

      iex> Issues.CLI.parse_args(["-h"])
      :help
  """
  @spec parse_args([String.t()]) :: {String.t(), String.t(), integer()} | :help
  def parse_args(argv) do
    OptionParser.parse(argv,
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    |> elem(1)
    |> args_to_internal_representation()
  end

  @doc """
  Convert the parsed arguments to an internal representation.

  ## Parameters
    - args: List of parsed arguments.

  ## Examples

      iex> Issues.CLI.args_to_internal_representation(["elixir-lang", "elixir", "5"])
      {"elixir-lang", "elixir", 5}

      iex> Issues.CLI.args_to_internal_representation(["elixir-lang", "elixir"])
      {"elixir-lang", "elixir", 4}

      iex> Issues.CLI.args_to_internal_representation(["-h"])
      :help
  """
  @spec args_to_internal_representation([String.t()]) ::
          {String.t(), String.t(), integer()} | :help
  def args_to_internal_representation([user, project, count]) do
    {user, project, String.to_integer(count)}
  end

  @spec args_to_internal_representation([String.t()]) ::
          {String.t(), String.t(), integer()} | :help
  def args_to_internal_representation([user, project]) do
    {user, project, @default_count}
  end

  @spec args_to_internal_representation(any()) :: :help
  def args_to_internal_representation(_) do
    :help
  end

  @doc """
  Process the parsed arguments.

  ## Parameters
    - args: Tuple of `{user, project, count}` or `:help`.

  ## Examples

      iex> Issues.CLI.process(:help)
      :ok

      iex> Issues.CLI.process({"elixir-lang", "elixir", 5})
      :ok
  """
  @spec process({String.t(), String.t(), integer()} | :help) :: :ok
  def process(:help) do
    IO.puts("""
    usage: issues <user> <project> [ count | #{@default_count} ]
    """)

    System.halt(0)
  end

  @spec process({String.t(), String.t(), integer()}) :: :ok
  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response()
    |> sort_into_descending_order()
    |> last(count)
    |> print_table_for_columns(["number", "created_at", "title"])
  end

  @doc """
  Sort the list of issues into descending order.

  ## Parameters
    - list_of_issues: List of issues.

  ## Returns
    The list of issues sorted into descending order.
  """
  @spec sort_into_descending_order(list(map())) :: list(map())
  def sort_into_descending_order(list_of_issues) do
    list_of_issues
    |> Enum.sort(fn i1, i2 ->
      i1["created_at"] >= i2["created_at"]
    end)
  end

  @doc """
  Return the last `count` items from the list.

  ## Parameters
    - list: List of items.
    - count: Number of items to return.

  ## Returns
    The last `count` items from the list.
  """
  @spec last(list(map()), integer()) :: list(map())
  def last(list, count) do
    list
    |> Enum.take(count)
    |> Enum.reverse()
  end

  @doc """
  Decode the response from the Github API.

  ## Parameters
    - response: Tuple of `{:ok, body}` or `{:error, error}`.

  ## Examples

      iex> Issues.CLI.decode_response({:ok, body})
      body

      iex> Issues.CLI.decode_response({:error, error})
      :ok
  """
  @spec decode_response({:ok, any()} | {:error, map()}) :: any()
  def decode_response({:ok, body}), do: body

  @spec decode_response({:error, map()}) :: :ok
  def decode_response({:error, error}) do
    IO.puts("Error fetching from Github: #{error["message"]}")
    System.halt(2)
  end
end
