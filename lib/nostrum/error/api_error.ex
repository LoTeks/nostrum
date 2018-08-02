defmodule Nostrum.Error.ApiError do
  @moduledoc """
  Represents a failed response from the API.

  This occurs when hackney or HTTPoison fail, or when the API doesn't respond with `200` or `204`.
  This should only occur when using the banged API methods.
  """

  defexception [
    :status_code,
    :response
  ]

  @type t :: %{
          status_code: status_code,
          response: response
        }

  @type status_code :: 100..511
  @type discord_status_code :: 10001..90001

  @type response :: String.t() | error | detailed_error

  @type detailed_error :: %{code: discord_status_code, message: String.t(), errors: errors}
  @type errors :: %{required(String.t()) => errors} | %{required(String.t()) => error_list_map}
  @type error_list_map :: %{_errors: [error]}
  @type error :: %{code: discord_status_code, message: String.t()}

  @impl true
  def message(%__MODULE__{response: response, status_code: nil}) when is_binary(response) do
    response
  end

  @impl true
  def message(%__MODULE__{response: response, status_code: nil}) do
    "#{inspect(response)}"
  end

  # TODO: pretty print for discord errors
  @impl true
  def message(%__MODULE__{
        response: %{code: error_code, message: message, errors: errors},
        status_code: code
      }) do
    "(HTTP #{code}) received Discord status code #{error_code} (#{message}) with errors: #{
      inspect(errors)
    }"
  end

  @impl true
  def message(%__MODULE__{response: %{code: error_code, message: message}, status_code: code}) do
    "(HTTP #{code}) received Discord status code #{error_code} (#{message})"
  end
end
