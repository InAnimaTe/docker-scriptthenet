## Scriptthe.net: The Docker Container

This container is used, in conjunction with some dependency containers, to provide my site, [scriptthe.net](https://scriptthe.net)

### How this works

This container is dependent off of the very excellent [yoshz/docker-ghost](https://github.com/yoshz/docker-ghost) container which inherits its configuration through runtime environment variables. If it wasn't for the theme and a few other configuration specifics, I wouldn't even need this container on top of yoshz's.

The below *example* [crane](https://github.com/michaelsauter/crane) configuration is a sample of how I deploy my blog utilizing multiple containers to provide storage and (eventually) database dependencies, but also with nginx so I can gain the ability to cache and handle static content a bit nicer:)

```yaml
containers:
    stn:
        image: inanimate/scriptthenet
        run:
            detach: true
            env: ["URL=http://scriptthe.net", "MAIL_SERVICE=Mailgun", "MAIL_USER=postmaster@scriptthe.net", "MAIL_PASS=7003a252980deb045709c7f9392f31b4", "DB_CLIENT=mysql", "DB_HOST=superawesome.db.com", "DB_PORT=3306", "DB_DATABASE=stn", "DB_USER=stn", "DB_PASSWORD=exampleexamplenopenopenope"]
            #publish: ["80:2368"]  // in case you ever want to work directly with ghost (minus nginx)
    stn-btsync:
        image: inanimate/btsync
        run:
            detach: true
            env: ["SYNC_DIR=/ghost/content/images", "SECRET=BNOTZLZQIP2ZVINGC4ZPUWGD3J23ABOJD"]
            volumes-from: ["stn"]
    stn-nginx:
        image: inanimate/nginx-ssl
        run:
            detach: true
            volumes-from: ["stn"]
            link: ["stn:stn"]
            publish: ["443:443"]
            env: ["SSL_KEY=-----BEGIN PRIVATE KEY-----\nOMNOMkkcldor7fd9s..", "SSL_CERT=-----BEGIN CERTIFICATE-----\nMIIGSzCCBTOgAwIBAgI..", "SSL_TRUST_CERT=-----BEGIN CERTIFICATE-----\nherpDERp9xidufDDDG.."]
```
So lets walk through this config:

* I define 3 different containers and name them in association through a common name `stn`. This is great because in example, if I have a `nginx` container already running on the host, this (stn-nginx) won't interfere.
* I leave a publish ports line under my main container in the event i want to bypass nginx for testing. Additionally, you'll want to change the publish under `stn-nginx` depending on your proxy solution for your host.
* `stn-btsync` and `stn-nginx` both pull /ghost and other volumes from the main stn container. For `btsync`, this allows it to do its syncing to the images dir. For nginx, this allows it to serve static content directly (see my site/server config for nginx) and also pull in the site configs I incorporate into this container.
* `stn-nginx` is setup to link with `stn` so that it can use the simple hostname of `stn` to connect to our ghost nodejs instance.
* After a lot of work, I settled on the only real way to pass through my certs and keys and do that to the nginx container. Note that nsenter currently won't work like this because these are env variables with spaces in them. More on this [here](https://github.com/InAnimaTe/docker-nginx-ssl/blob/master/README.md).

### Why I did it like this...srsly, who passes ssl certs as vars?

The idea here was to fully abstract away the need to rely on essential configuration data sitting across multiple config files. Additionally, I really wanted to share this container/image with the world so it occurred to me that I should try to utilize my "service" file to hold private information and config data that gets applied at container runtime. 

This is the first time I've gone to this length in pursuit of a modular, multi-container, single-file defined application stack. Overall, this isn't for everyone and really varies depending on the application, your storage location of images, and your overall openness of information.

Looking back, I'm pretty sure if I was keeping this image/repo private, I would definitely have my ssl certs and key sitting in a file that get added in at build time. I probably would do a few other things differently too. But overall, using runtime parameters existent in a single file is just really convienient;)
