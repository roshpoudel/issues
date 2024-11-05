defmodule Issues.GithubIssues do
  @moduledoc """
  A module to fetch issues from a GitHub repository.
  """
  require Logger

  @user_agent [{"User-agent", "Elixir dave@pragprog.com"}]

  @doc """
  Fetches issues from the specified GitHub repository.

  ## Parameters
  - user: The GitHub username.
  - project: The GitHub repository name.

  ## Returns
  A tuple with the status and the parsed body of the response.
  """
  @spec fetch(String.t(), String.t()) :: {:ok | :error, map()}
  def fetch(user, project) do
    Logger.info("Fetching #{user}'s project #{project}")

    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  @doc """
  Constructs the URL for fetching issues from a GitHub repository.

  ## Parameters
  - user: The GitHub username.
  - project: The GitHub repository name.

  ## Returns
  The URL as a string.
  """
  @spec issues_url(String.t(), String.t()) :: String.t()
  def issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  @doc """
  Handles the HTTP response from the GitHub API.

  ## Parameters
  - response: A tuple containing the status and the response body.

  ## Returns
  A tuple with the status and the parsed body of the response.
  """
  @spec handle_response({atom(), %{status_code: integer(), body: String.t()}}) ::
          {:ok | :error, map()}
  def handle_response({_, %{status_code: status_code, body: body}}) do
    Logger.info("Got response: status code=#{status_code}")
    Logger.debug(fn -> inspect(body) end)

    {
      status_code |> check_for_error(),
      body |> Poison.Parser.parse!()
    }
  end

  @spec check_for_error(integer()) :: :ok | :error
  defp check_for_error(200), do: :ok
  defp check_for_error(_), do: :error
end
