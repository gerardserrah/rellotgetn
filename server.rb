require 'webrick'

root = File.expand_path(File.dirname(__FILE__))

mime_types = WEBrick::HTTPUtils::DefaultMimeTypes
mime_types['mp3'] = 'audio/mpeg'
mime_types['m4a'] = 'audio/mp4'
mime_types['ttf'] = 'font/ttf'
mime_types['json'] = 'application/json'

server = WEBrick::HTTPServer.new(
  Port: 8080,
  DocumentRoot: root,
  MimeTypes: mime_types,
  AccessLog: [],
  Logger: WEBrick::Log.new(File::NULL)
)

trap('INT') { server.shutdown }
puts "Servidor en marxa a http://localhost:8080/"
server.start
