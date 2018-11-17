# `Receiver` still receives the webhook and parses it but instead of sending it directly to its endpoint it now passes the webhook to the pipeline defined in `Processor.process`
defmodule Receiver do

  def receive(raw_webhook) do
    parsed_webhook = Parser.parse(raw_webhook)
    case parsed_webhook do
      {:ok, endpoint, payload, created_at} ->
        # create the initial webhook pipeline state and start the pipeline
        %WebhookState{
          endpoint: endpoint,
          payload: payload,
          created_at: created_at
        }
        |> Processor.process()
      {:error, error_msg} -> Logger.error("error - #{error_msg}")
    end
  end

end
