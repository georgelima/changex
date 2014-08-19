defmodule Changex.Formatter.Markdown do

  @moduledoc """
  Output the formatted changelog to the terminal in markdown format.
  """

  @doc """
  Take a map of commits in the following format:

      %{
        fix: %{
          scope1: [commit1, commit2],
          scope2: [commit5, commit6]
        }
        feat: %{
          scope1: [commit3, commit4],
          scope2: [commit7, commit8]
        }
      }

  And output them to the terminal in the following format:

      # v0.0.1

      ## Bug Fixes

       * **Scope 1**
        * commit 1 - hash
        * commit 2 - hash
      *  **Scope 2**
        * commit 5 - hash
        * commit 6 - hash

      ## Features

       * **Scope 1**
        * commit 3 - hash
        * commit 4 - hash
       * **Scope 2**
        * commit 7 - hash
        * commit 8 - hash

  """
  def output(commits, version \\ nil) do
    "# #{(version || Keyword.get(Mix.Project.config, :version))}\n"
    |> IO.puts

    types
    |> Enum.each(fn (type) -> output_type(type, Dict.get(commits, type)) end)
  end

  defp output_type(type, commits) when is_map(commits) do
    "## #{type |> lookup}\n" |> IO.puts
    commits
    |> Enum.each(&output_commit_scope/1)
  end
  defp output_type(type, _), do: nil

  defp output_commit_scope({scope, commits}) do
    output = " * **#{to_string(scope)}**"
    commits
    |> Enum.reduce(output, fn (commit, acc) -> build_commits(commit, acc) end)
    |> IO.puts
  end

  defp build_commits(commit, acc) do
    hash = Keyword.get(commit, :hash)
    acc <> "\n  * #{Keyword.get(commit, :description)} (#{hash})"
  end

  defp types, do: [:fix, :feat, :perf]

  defp lookup(:fix), do: "Bug Fixes"
  defp lookup(:feat), do: "Features"
  defp lookup(:perf), do: "Performance Improvements"

end
