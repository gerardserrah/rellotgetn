require 'webrick'

root = File.expand_path(File.dirname(__FILE__))

mime_types = WEBrick::HTTPUtils::DefaultMimeTypes
mime_types['mp3'] = 'audio/mpeg'
mime_types['m4a'] = 'audio/mp4'
mime_types['mp4'] = 'video/mp4'
mime_types['ttf'] = 'font/ttf'
mime_types['otf'] = 'font/otf'
mime_types['woff2'] = 'font/woff2'
mime_types['json'] = 'application/json'

server = WEBrick::HTTPServer.new(
  Port: 8080,
  DocumentRoot: root,
  MimeTypes: mime_types,
  AccessLog: [],
  Logger: WEBrick::Log.new(File::NULL),
  RequestCallback: proc do |req, res|
    res['Accept-Ranges'] = 'bytes'
    res['Access-Control-Allow-Origin'] = '*'
  end
)

trap('INT') { server.shutdown }
puts "Servidor en marxa a http://localhost:8080/"
server.start
