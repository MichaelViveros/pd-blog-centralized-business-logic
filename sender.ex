# `Sender` sends the webhook to its endpoint. It also handles the different types of responses returned from the endpoint by persisting them to the db
defmodule Sender do

  def send(endpoint, payload) do
    HTTP.post(endpoint, payload)
    |> handle_response(endpoint, payload)
  end

  defp handle_response(response = {200, response_body}, endpoint, payload) do
    Logger.info("webhook sent successfully")
    DB.save_successful_response(endpoint, payload, response_body)
  end

  defp handle_response(response = {404, response_body}, endpoint, payload) do
    Logger.error("failed to send webhook, endpoint returned 404")
    DB.save_failed_response(endpoint, payload, response_body)
  end

end
