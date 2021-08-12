
def response_generator(status, message = nil, options = {})
  response = {
    data: options,
    status: status
  }
  response[:message] = message if not message.nil?
  response.to_json
end