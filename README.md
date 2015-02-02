## Scriptthe.net: The Docker Container

This container is used, in conjunction with some dependency containers, to provide my site, [scriptthe.net](https://scriptthe.net)

### How this works

This container is dependent off of the very excellent [yoshz/docker-ghost](https://github.com/yoshz/docker-ghost) container which inherits its configuration through runtime environment variables. If it wasn't for the theme and a few other configuration specifics, I wouldn't even need this container on top of yoshz's.

The supplied example crane configuration is a sample of how I deploy my blog utilizing multiple containers to provide storage and database dependencies, but also with nginx so I can gain the ability to cache and handle static content a bit better:)
