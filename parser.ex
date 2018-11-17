# `Parser` is now solely responsible for decoding the webhook from a JSON string
defmodule Parser do

  def parse(raw_webhook) do
    decoded_webhook = JSON.decode(raw_webhook)
    endpoint = decoded_webhook.event.endpoint
    payload = decoded_webhook.event.payload
    created_at = decoded_webhook.event.created_at

    # no more expired webhook logic :) !

    {:ok, endpoint, payload, created_at}
  end

end
