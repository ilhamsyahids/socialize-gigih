
def response_generator(status, message = nil, options = {})
  options = options.merge(:status => status)
  if not message.nil?
    options.merge!(:message => message)
  end
  options.to_json
end