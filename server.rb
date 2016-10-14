require 'socket'
require './conf'
require 'optparse'
require 'uri'

OptionParser.new do |opt|
  opt.on('-c NCPU') { |o| AMOUNT_CPU = o }
  opt.on('-r ROOTDIR') { |o| PROJECT_ROOT = o }
  opt.on('-p PORT') { |o| PORT = o }
end.parse!

puts AMOUNT_CPU
puts PROJECT_ROOT


server = TCPServer.new(HOST, PORT);

STDERR.puts("Listening on #{HOST}: #{PORT}")
STDERR.puts("Spawning #{AMOUNT_WORKERS} workers")
def content_type(path)
  ext = File.extname(path).split(".").last
  puts ext
  CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
end


def requested_file(request_line)
  request_uri  = request_line.split(" ")[1]
  path         = URI.unescape(URI(request_uri).path)

  clean = []

  # Split the path into components
  parts = path.split("/")

  parts.each do |part|
    #puts part
    # skip any empty or current directory (".") path components
    next if part.empty? || part == '.'
    # If the path component goes up one directory level (".."),
    # remove the last clean component.
    # Otherwise, add the component to the Array of clean components
    part == '..' ? clean.pop : clean << part
  end

  # return the web root joined to the clean path
  #puts clean
  File.join(PROJECT_ROOT, *clean)
end


  
loop do
  socket = server.accept
  request_line = socket.gets
  STDERR.puts request_line
  path = requested_file(request_line)
  puts path
  if File.exist?(path) && !File.directory?(path)
    time = Time.new()
    File.open(path, "rb") do |file|
      socket.print "HTTP/1.1 200 OK\r\n" +
                       "Content-Type: #{content_type(file)}\r\n" +
                       "Content-Length: #{file.size}\r\n" +
                       "Connection: close\r\n"
                       "Date: #{time.inspect}\r\n" +
                       "Server: #{SERVER_NAME}"

      socket.print "\r\n"

      # write the contents of the file to the socket
      IO.copy_stream(file, socket)
    end
  else
    message = "File not found\n"
    socket.print "HTTP/1.1 404 Not Found\r\n" +
                     "Content-Type: text/plain\r\n" +
                     "Content-Length: #{message.size}\r\n" +
                     "Connection: close\r\n"
                     "Date: #{time.inspect}\r\n" +
                     "Server: #{SERVER_NAME}"

    socket.print "\r\n"

    socket.print message
  end
  socket.close
end