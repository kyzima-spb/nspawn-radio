settings.init.allow_root := true


# Функция чтения значения из XML файла
def xml(filename, xpath)
  string.trim(
    process.read(
      "xmlstarlet sel -t -v '#{xpath}' '#{filename}'"
    )
  )
end


# 
def create_output(config, icecast)
  source =
    if config.source.type == "directory" then
      media_path = null.get(config.source.path)
      mksafe(playlist(media_path))
    elsif config.source.type == "blank" then
      blank()
    else
      error.raise(error.failure, "unknown source type '#{config.source.type}'")
    end
  
  output.icecast(
    %vorbis,
    host = icecast.host,
    port = icecast.port,
    password = icecast.password,
    mount = config.mount,
    name = config.name,
    description = config.description,
    source
  )
end


# Возвращает параметры подключения к Icecast
def read_icecast_credentials(filename)
  {
    host = "localhost",
    port = int_of_string(xml(filename, "/icecast/listen-socket/port")),
    password = xml(filename, "/icecast/authentication/source-password")
  }
end


icecast_config = read_icecast_credentials(
  environment.get("ICECAST_CONFIG", default="/etc/icecast2/icecast.xml")
)

let json.parse (streams : [
  {
    mount: string,
    name: string,
    description: string,
    source: {
      type: string,
      path: string?,
      genre: string?
    }
  }
]) = file.contents("/etc/liquidsoap/streams.json")

list.iter(
  fun(stream) -> create_output(stream, icecast_config),
  streams
)
