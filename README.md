# Gitea
Small code hosting platform.

## Running the server
```bash
docker run --detach --name gitea --publish 3022:3022 --publish 3000:3000 hetsh/gitea
```

## Stopping the container
```bash
docker stop gitea
```

## Storage & Permissions
Create persistent storage on your host to avoid data loss:
```bash
STORAGE="/path/to/storage"
mkdir -p "$STORAGE/config"
mkdir -p "$STORAGE/data"
mkdir -p "$STORAGE/log"
chown -R 1360:1360 "$STORAGE"
```
`1360` is the numerical id of the user running the server (see Dockerfile).
The user must have RW access to the storage directory.
Start the server with the additional mount parameters:
```bash
docker run --mount type=bind,source=/path/to/storage,target=/gitea ...
```

## Configuration
Gitea is configured via its [web interface](http://localhost:3000).
A configuration wizard will guide you through the initial setup if you run the server for the first time.

## Time
Share the timezone of your host to display the correct timestamp in logs:
```bash
docker run --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly ...
```
