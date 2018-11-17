# `DB` didn't have any business logic in the first place so it remained unchanged
defmodule DB do

  def save_successful_response(endpoint, payload, response) do
    MySQL.insert('successes', endpoint, payload, response)
  end

  def save_failed_response(endpoint, payload, response) do
    MySQL.insert('failures', endpoint, payload, response)
  end

end
