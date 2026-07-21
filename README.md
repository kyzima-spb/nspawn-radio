```
[Exec]
NotifyReady=yes
PrivateUsers=yes

[Network]
VirtualEthernet=yes
Port=tcp:8000:8000

[Files]
BindReadOnly=/etc/liquidsoap/streams.json:/etc/liquidsoap/streams.json
BindReadOnly=/media/data/music:/music
```


## Конфигурация потоков

```json
[
  {
    "mount": "/silent.ogg",
    "name": "Silence test stream",
    "description": "If you don't hear anything, then it's okay",
    "source": {"type": "blank"}
  },
  {
    "mount": "/avril.ogg",
    "name": "Avril Lavigne",
    "description": "Full discography",
    "source": {"type": "directory", "path": "/music"}
  },
  {
    "mount": "/avril.ogg",
    "name": "Avril Lavigne",
    "description": "Full discography",
    "source": {"type": "library", "genre": "punk"}
  },
]
```

## Разработка

Сборка для локального запуска:

```shell
cd image
sudo -E ../env/bin/mkosi --profile nginx --format directory --tools-tree yes build --incremental yes --force
sudo -E ../env/bin/mkosi --profile nginx --format directory boot
```
