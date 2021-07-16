defmodule Mix.Tasks.Esbuild.Install do
  use Mix.Task

  @impl true
  def run([version]) do
    tmp_dir = Path.join(System.tmp_dir!(), "phx-esbuild")
    File.rm_rf!(tmp_dir)
    File.mkdir_p!(tmp_dir)

    name = "esbuild-#{target()}"
    url = "https://registry.npmjs.org/#{name}/-/#{name}-#{version}.tgz"
    tar = fetch_body!(url)

    case :erl_tar.extract({:binary, tar}, [:compressed, cwd: tmp_dir]) do
      :ok -> :ok
      other -> raise "couldn't upack archive: #{inspect(other)}"
    end

    bin_path = Esbuild.bin_path()
    File.rename!(Path.join([tmp_dir, "package", "bin", "esbuild"]), bin_path)

    version = Esbuild.cmd!(bin_path, ["--version"], [])
    version = String.trim(version)
    Mix.shell().info("downloaded esbuild #{version}")
  end

  def run(_) do
    Mix.raise("""
    Invalid arguments, expected one of:

    mix esbuild.install VERSION
    """)
  end

  # Available targets: https://github.com/evanw/esbuild/tree/master/npm
  defp target() do
    case :erlang.system_info(:system_architecture) do
      # darwin

      'x86_64-apple-darwin' ++ _ ->
        "darwin-64"

      'aarch64-apple-darwin' ++ _ ->
        "darwin-arm64"

      # linux

      'x86_64-linux' ++ _ ->
        "linux-64"

      'aarch64-linux' ++ _ ->
        "linux-arm64"

      # windows

      'win32' ->
        "windows-#{:erlang.system_info(:wordsize) * 8}"

      other ->
        raise "#{other} is not supported."
    end
  end

  defp fetch_body!(url) do
    url = String.to_charlist(url)
    Mix.shell().info("downloading #{url}")

    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)

    # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/inets
    cacertfile = CAStore.file_path() |> String.to_charlist()

    http_options = [
      ssl: [
        verify: :verify_peer,
        cacertfile: cacertfile,
        depth: 2,
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    ]

    options = [body_format: :binary]

    case :httpc.request(:get, {url, []}, http_options, options) do
      {:ok, {{_, 200, _}, _headers, body}} ->
        body

      other ->
        raise "couldn't fetch #{url}: #{inspect(other)}"
    end
  end
end
