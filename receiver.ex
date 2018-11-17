# `Receiver` receives the webhook (duhh) from the upstream service, extracts the webhook from the received JSON string via `Parser` and then sends the webhook to its endpoint via `Sender`
defmodule Receiver do

  def receive(raw_webhook) do
    parsed_webhook = Parser.parse(raw_webhook)
    case parsed_webhook do
      {:ok, endpoint, payload} ->
        # if it was parsed successfully, send it to its endpoint
        Sender.send(endpoint, payload)
      {:error, error_msg} ->
        # if an error was returned from trying to parse it, don't send it
        Logger.error("error - #{error_msg}")
    end
  end

end
