# `Parser` decodes the webhook from a JSON string. It also raises an error if the webhook expired
defmodule Parser do

  @expired_threshold_seconds 5

  def parse(raw_webhook) do
    decoded_webhook = JSON.decode(raw_webhook)
    endpoint = decoded_webhook.event.endpoint
    payload = decoded_webhook.event.payload

    time_since_created = decoded_webhook.event.created_at - Time.now
    is_expired = time_since_created > @expired_threshold_seconds * 1000
    case is_expired do
      true -> {:error, "webhook expired"}
      false -> {:ok, endpoint, payload}
  end

end
