defmodule Processor do

  @expired_threshold_seconds 5

  # `WebhookState` defines the state used by the pipeline at the top of the `Processor` module
  defmodule WebhookState do

    defstruct(
      endpoint_url: "",
      payload: "",
      created_at: "",
      response: "",
      result: ""
    )

  end

  def process(webhook = %WebhookState{}) do
    # here is the pipeline containing all the business logic :) !
    # if the current stage returns an :ok, we move onto the next stage
    # if it returns an :error, the pipeline is stopped and we move
    # onto the error handler in the else block at the bottom
    with(
      {:ok, webhook} <- check_webhook_expired(webhook),
      {:ok, webhook} <- send_webhook(webhook),
      {:ok, webhook} <- handle_response(webhook),
      {:ok} <- save_response_to_db(webhook)
    ) do
      Logger.info("webhook processed successfully :) !")
      :ok
    else
      {:error, msg} ->
        msg = "error processing webhook :( ! - #{msg}"
        Logger.error(msg)
        :error
    end
  end

  defp check_webhook_expired(webhook = %WebhookState{created_at: created_at}) do
    # this was moved from Parser to here :) !
    time_since_created = created_at - Time.now
    is_expired = time_since_created > @expired_threshold_seconds * 1000
    case is_expired do
      true ->
        # if the webhook is expired, return an :error to stop the pipeline
        {:error, "webhook expired"}
      false -> {:ok, webhook}
    end
  end

  defp send_webhook(webhook = %WebhookState{endpoint_url: endpoint_url, payload: payload}) do
    {status_code, response_body} = Sender.send(endpoint_url, payload)
    # store the response returned from the endpoint in WebhookState so
    # that the next stage of the pipeline (handle_response) can access it
    webhook = %WebhookState{webhook | response: {status_code, response_body}
    {:ok, webhook}
  end

  defp handle_response(webhook = %WebhookState{response: {200, _response_body}}) do
    # this was moved from Sender to here :) !
    Logger.info("webhook sent successfully")
    # store the result in WebhookState so that the next stage of the
    # pipeline (save_response_to_db) can access it
    webhook = %WebhookState{webhook | result: "success"}
    {:ok, webhook}
  end

  defp handle_response(webhook = %WebhookState{response: {404, _response_body}}) do
    # this was moved from Sender to here :) !
    Logger.error("failed to send webhook, endpoint returned 404")
    # store the result in WebhookState so that the next stage of the
    # pipeline (save_response_to_db) can access it
    webhook = %WebhookState{webhook | result: "failure"}
    {:ok, webhook}
  end

  defp save_response_to_db(webhook = %WebhookState{
    result: "success",
    endpoint: endpoint,
    payload: payload,
    response: {_status_code, response_body}
  }) do
    # this was moved from Sender to here :) !
    DB.save_successful_response(endpoint, payload, response_body)
    {:ok}
  end

  defp save_response_to_db(webhook = %WebhookState{
    result: "failure",
    endpoint: endpoint,
    payload: payload,
    response: {_status_code, response_body}
  }) do
    # this was moved from Sender to here :) !
    DB.save_failed_response(endpoint, payload, response_body)
    {:ok}
  end

end
