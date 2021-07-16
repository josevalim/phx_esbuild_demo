defmodule Esbuild do
  def bin_path do
    Path.join(Path.dirname(Mix.Project.build_path()), "esbuild")
  end

  @doc false
  def cmd!(cmd, args, opts) do
    case System.cmd(cmd, args, opts) do
      {result, 0} ->
        result

      {_, status} ->
        Mix.raise("command exited with #{status}")
    end
  end
end
