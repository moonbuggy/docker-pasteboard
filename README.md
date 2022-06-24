# Docker Pasteboard
[Pasteboard][source-repo] running in Alpine behind Nginx, built for multiple architectures.

## Usage
```
docker run -d --name pasteboard \
  -p 8080:8080 \
  -v pasteboard_storage:/pasteboard/public/storage \
  moonbuggy2000/pasteboard:latest
```

Refer to the [source repo][source-repo] for more detailed instructions.

### Environment variables
*   `PB_ORIGIN`      - the domain Pasteboard is being run on (default: `pasteboard.co`)
*   `PB_MAX`         - maximum time, in days, to retain images (default: `7`, `false` for unlimited)
*   `NGINX_LOG_ALL`  - enable logging of HTTP 200 and 300 responses (accepts: `true`, `false` default: `false`)
*   `NGINX_PORT`     - outward facing Nginx port (default: `8080`)
*   `NGINX_BUFFER`   - sets _client_body_buffer_size_ and _client_max_body_size_ in Nginx (default: `5M`)
*   `PUID`           - user ID to run as (default: `1000`)
*   `PGID`           - group ID to run as (default: `1000`)
*   `TZ`             - set timezone

The `NGINX_BUFFER` setting allows an uploaded image to be buffered in memory by the Nginx proxy, rather than using the disk for temporary storage. It can be increased if larger uploads are generating '_a client request body is buffered to a temporary file_' warnings in the log.

`PUID`/`PGID` will be the owner of images in the mounted volume, so set permissions accordingly.

## Links
*   GitHub: <https://github.com/moonbuggy/docker-pasteboard>
*   DockerHub: <https://hub.docker.com/r/moonbuggy2000/pasteboard>


### Source
*   <https://github.com/moonbuggy/pasteboard>
*   <https://github.com/AnthoDingo/pasteboard>
*   <https://github.com/JoelBesada/pasteboard>

[source-repo]: https://github.com/moonbuggy/pasteboard
