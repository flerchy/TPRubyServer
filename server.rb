require 'concurrent'
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

amount_cpu = [AMOUNT_CPU.to_i / 2, Concurrent.processor_count].min

processes = Queue.new
server = TCPServer.new(HOST, PORT);

STDERR.puts("Listening on #{HOST}: #{PORT}")
STDERR.puts("Spawning #{AMOUNT_WORKERS} workers")

amount_cpu.times do
  fork
end

def content_type(path)
  ext = File.extname(path).split(".").last
  puts ext
  CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
end

thread = Thread.new {
  while true
    if !processes.empty?
      client = processes.pop(true) rescue nil
      if client
        master(client)
      end
    end

    if interrupt
      break
    end
  end
}

def requested_file(request_line)
  request_uri  = request_line.split(" ")[1]
  path         = URI.unescape(URI(request_uri).path)

  clean = []

  # Split the path into components
  parts = path.split('/')

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





def get_headers(status, type=nil, length=nil, last_modified=nil, allow=false)
  time = Time.new()
  headers = [
      "#{PROTOCOL} #{status} #{STATUS_DICT[status]}",
      "Date: #{time.inspect}",
      "Server: #{SERVER_NAME}"
  ]

  if status == 200
    headers += [
        "Content-Type: #{type}",
        "Content-Length: #{length}",
        "Last-Modified: #{last_modified}"
    ]
  end

  if allow
    headers += ["Allow: #{ALLOW_METHODS}"]
  end

  headers += ["Connection: #{CONNECTION_TOKEN}", "", ""]
  headers.join("\r\n")
end
