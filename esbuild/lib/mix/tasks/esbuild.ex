defmodule Mix.Tasks.Esbuild do
  use Mix.Task

  @esbuild_latest_version "0.12.15"

  @impl true
  def run(args) do
    bin_path = Esbuild.bin_path()

    unless File.exists?(bin_path) do
      Mix.Tasks.Esbuild.Install.run([@esbuild_latest_version])
    end

    Mix.shell().info("running esbuild #{Enum.join(args, " ")}")
    Esbuild.cmd!(bin_path, args, into: IO.stream())
  end
end
