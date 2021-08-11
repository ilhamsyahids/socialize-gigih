
def find_hashtag(text)
  array = text.scan(/\#\w+/).map(&:downcase)
  array = array.uniq
end
