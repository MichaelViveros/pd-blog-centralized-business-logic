# `Sender` is now solely responsible for sending the webhook to its endpoint:
defmodule Sender do

  def send(endpoint, payload) do
    HTTP.post(endpoint, payload)
  end

  # no more logic about handling different types of responses and storing them to the db :) !

end
