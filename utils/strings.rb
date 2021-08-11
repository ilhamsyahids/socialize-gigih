
def find_hashtag(text)
  text.scan(/\#\w+/).map(&:downcase)
end
