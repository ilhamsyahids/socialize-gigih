require 'securerandom'

def save_to_server(file)
  tempfile = file[:tempfile]
  filename = file[:filename]
  extension = File.extname(filename)
  uuid = SecureRandom.uuid
  folder = extension
  if not ['.png', '.jpg', '.jpeg', '.gif', '.mp4'].include?(extension)
    folder = '.file'
  end
  folder = folder[1..-1]
  folder_path = "assets/#{folder}"
  path = "#{folder_path}/#{uuid}#{extension}"
  FileUtils.mkdir_p "./#{folder_path}"
  FileUtils.copy(tempfile.path, "./#{path}")
  return [filename, path]
end
