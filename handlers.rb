require 'server.rb'
require 'mimemagic'
require 'mimemagic/overlay'

def master(client)
  msg = client.gets.split

  method = msg[0]
  path = msg[1]
  protocol = msg[2]

  if !method || !path or !protocol
    client.puts get_headers(STATUS_FORBIDDEN)
    client.close
    return
  end

  path = path.gsub(/\?.*/, '')

  if path.include?('/../')
    client.puts get_headers(STATUS_FORBIDDEN)
    client.close
    return
  end

  begin
    case method
      when 'GET'
        get_handler(client, path)
      when 'HEAD'
        head_handler(client, path)
      when 'OPTIONS', 'POST', 'PUT', 'PATCH', 'DELETE', 'TRACE', 'CONNECT'
        not_allowed_handler(client)
      else
        not_implemented_handler(client)
    end
  rescue
    # client.close
  end
end


def head_handler(client, path)
  get_handler(client, path, body=false)
end


def not_implemented_handler(client)
  client.puts get_headers(STATUS_NOT_IMPLEMENTED, nil, nil, nil, allow=true)
  client.close
end


def not_allowed_handler(client)
  client.puts get_headers(STATUS_METHOD_NOT_ALLOWED, nil, nil, nil, allow=true)
  client.close
end

def get_handler(client, path, body=true)
  path = URI.unescape(File.join(DOCUMENT_ROOT, path))

  if File.file?(path) and path.end_with?(INDEX_PATH)
    client.puts get_headers(STATUS_FORBIDDEN)
    client.close
  end

  if File.directory?(path)
    path = File.join(path, INDEX_PATH)
  end

  if File.exist?(path)
    mime = MimeMagic.by_path(path).type
    size = File.size?(path)
    modified_time = File.mtime(path).strftime(HTTP_DATE_FORMAT)

    client.puts get_headers(STATUS_OK, mime, size, modified_time)
    if body
      File.open(path, 'rb') do |file|
        while chunk = file.read(FILE_CHUNK_SIZE)
          client.write chunk
        end
      end
    end
  else
    client.puts get_headers(STATUS_NOT_FOUND)
  end

  client.close
end