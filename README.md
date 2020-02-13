# Gitea
Super small GitHub alternative.

## Running the server
```bash
docker run --detach --name gitea --publish 80:80 --publish 443:443 hetsh/gitea
```

## Stopping the container
```bash
docker stop gitea
```

## Configuring
TVHeadend is configured via its [web interface](http://localhost:443).
A configuration wizard will guide you through the initial setup if you run the server for the first time.
Remember to mount persistent storage if you want to keep the configuration.

## Creating persistent storage
```bash
CONF="/etc/gitea/app.ini"
REPOS="/var/lib/gitea/repos/"
mkdir -p "$REPOS"
chown -R 1360:1360 "$REPOS"
```
`1360` is the numerical id of the user running the server (see Dockerfile).
The user must have RW access to the configuration and recordings directory.
Start the server with the additional mount flags:
```bash
docker run --mount type=bind,source=/path/to/configuration,target=/home/hts/.hts/gitea --mount type=bind,source=/path/to/recordings,target=/home/hts/rec ...
```

## Automate startup and shutdown via systemd
```bash
systemctl enable gitea --now
```
The systemd unit can be found in my [GitHub](https://github.com/Hetsh/docker-gitea) repository.
By default, the systemd service assumes `/etc/gitea` for configuration and `/opt/recordings` for recordings.
You need to adjust these to suit your setup.

## Fork Me!
This is an open project (visit [GitHub](https://github.com/Hetsh/docker-gitea)). Please feel free to ask questions, file an issue or contribute to it.
