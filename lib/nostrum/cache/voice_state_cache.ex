defmodule Nostrum.Cache.VoiceStateCache do
  @moduledoc """
  Cache for voice states.

  The ETS table name associated with the Voice State Cache is `:voice_states`. Besides the
  methods provided below you can call any other ETS methods on the table.

  ## Example
  ```elixir
  info = :ets.info(:voice_states)
  [..., heir: :none, name: :voice_states, size: 1, ...]
  size = info[:size]
  1
  ```
  """

  alias Nostrum.Struct.{Guild, User}
  alias Nostrum.Util

  import Nostrum.Snowflake, only: [is_snowflake: 1]

  @doc ~S"""
  Retreives a voice state for a user from the cache by guild and id.

  If successful, returns `{:ok, voice_state}`. Otherwise returns `{:error, reason}`.

  ## Example
  ```elixir
  case Nostrum.Cache.VoiceStateCache.get(111133335555, 222244446666) do
    {:ok, _voice_state} ->
      "They're online!"
    {:error, _reason} ->
      "They're dead Jim"
  end
  ```
  """
  @spec get(User.id(), Guild.id()) :: {:error, :voice_state_not_found} | {:ok, map}
  def get(user_id, guild_id) when is_snowflake(user_id) and is_snowflake(guild_id) do
    case :ets.lookup(:voice_states, {user_id, guild_id}) do
      [] -> {:error, :voice_state_not_found}
      [{{^user_id, ^guild_id}, voice_state}] -> {:ok, voice_state}
    end
  end

  @doc """
  Same as `get/1`, but raises `Nostrum.Error.CacheError` in case of a failure.
  """
  @spec get!(User.id(), Guild.id()) :: no_return | map
  def get!(user_id, guild_id) when is_snowflake(user_id) and is_snowflake(guild_id) do
    user_id |> get(guild_id) |> Util.bangify_find({user_id, guild_id}, __MODULE__)
  end

  @doc false
  @spec create(map) :: :ok
  def create(voice_state) do
    :ets.insert(:voice_states, {{voice_state.user_id, voice_state.guild_id}, voice_state})
    :ok
  end

  @doc false
  @spec update(map) :: {Guild.id(), nil | map, map} | :noop
  def update(voice_state) do
    case get(voice_state.user_id, voice_state.guild_id) do
      {:ok, vs} ->
        new_voice_state = Map.merge(vs, voice_state)
        create(new_voice_state)

        if vs.channel_id == new_voice_state.channel_id
          and vs.deaf == new_voice_state.deaf
          and vs.mute == new_voice_state.mute
          and vs.self_deaf == new_voice_state.self_deaf
          and vs.self_mute == new_voice_state.self_mute
          and vs.self_stream == new_voice_state.self_stream
          and vs.self_video == new_voice_state.self_video
          and vs.suppress == new_voice_state.suppress,
            do: :noop,
            else: {voice_state.guild_id, vs, new_voice_state}

      {:error, _} ->
        create(voice_state)
        {voice_state.guild_id, nil, voice_state}
    end
  end

  @doc false
  @spec bulk_create(Guild.id(), [map]) :: :ok
  def bulk_create(_, []), do: :ok

  def bulk_create(guild_id, voice_states) when is_list(voice_states) do
    Enum.each(voice_states, fn vs ->
      :ets.insert(:voice_states, {{vs.user_id, guild_id}, vs})
    end)
  end
end
