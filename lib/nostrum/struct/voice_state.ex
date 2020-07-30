defmodule Nostrum.Struct.VoiceState do
  @moduledoc """
  Struct representing a Discord voice state.
  """

  alias Nostrum.Struct.Guild.{Member}
  alias Nostrum.{Snowflake}

  defstruct [
    :guild_id,
    :channel_id,
    :user_id,
    :member,
    :session_id,
    :deaf,
    :mute,
    :self_deaf,
    :self_mute,
    :self_stream,
    :self_video,
    :suppress
  ]

  @typedoc "The guild id this voice state is for"
  @type guild_id :: Snowflake.t() | nil

  @typedoc "The channel id this user is connected to"
  @type channel_id :: Snowflake.t() | nil

  @typedoc "The user id this voice state is for"
  @type user_id :: Snowflake.t()

  @typedoc "The guild member this voice state is for"
  @type member :: Member.t() | nil

  @typedoc "The session id for this voice state"
  @type session_id :: String.t()

  @typedoc "Whether this user is deafened by the server"
  @type deaf :: boolean

  @typedoc "Whether this user is muted by the server"
  @type mute :: boolean

  @typedoc "Whether this user is locally deafened"
  @type self_deaf :: boolean

  @typedoc "Whether this user is locally muted"
  @type self_mute :: boolean

  @typedoc "Whether this user is streaming using \"Go Live\""
  @type self_stream :: boolean | nil

  @typedoc "Whether this user's camera is enabled"
  @type self_video :: boolean

  @typedoc "Whether this user is muted by the current user"
  @type suppress :: boolean
end
