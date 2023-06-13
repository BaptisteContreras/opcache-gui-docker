# opcache-gui docker

This Dockerfile lets you build and serve the awesome [Opcache GUI](https://github.com/amnuts/opcache-gui) application.

All credit for the application `opcache-gui` goes to **https://github.com/amnuts**.

*This image was tested on opcache-gui:3.4.0*

## How does this work ?
This image creates the index.php for opcache-gui and start a Nginx server on port 80.

You only have **three things** to do to make it work :
- Provide a valid REMOTE_PHPFPM_HOST and REMOTE_PHPFPM_PORT and build the image
- Create a named volume to access the /app/index.php outside the container
- Make the index.php accessible for your PHPFPM

Note : For the moment this only works with a **PHPFPM inside a docker container**.

## How to use ?

### 1) Build the image locally

First of all, clone this repo
```bash
    git clone https://github.com/BaptisteContreras/opcache-gui-docker.git
```

Then go into the cloned repo and build the image
```bash
DOCKER_BUILDKIT=1 docker build --build-arg REMOTE_PHPFPM_HOST=127.0.0.1 --build-arg REMOTE_PHPFPM_PORT=9000 -t opcache-gui .
```
Build arguments to provide : 
- **REMOTE_PHPFPM_HOST** : Is the host of the PHPFPM process. it can be a hostname, a container name or an IPV4 address.
- **REMOTE_PHPFPM_PORT** : Is the port of the PHPFPM process. By default, it's set to **9000**

### 2) Use the image with docker-composer

The easiest way to use this image is with a docker-compose file like so :

```yaml
# docker-compose.yaml

version: '2'

services:
  demo-phpfpm:
    build: 'php:8.1-fpm-buster'
    volumes:
      - opcache-gui-shared:/opcache-gui

  opcache-gui:
    image: 'opcache-gui:latest'
    ports:
      - '8080:80'
    volumes:
      - opcache-gui-shared:/app

volumes:
  opcache-gui-shared:
    external: false

```

Note : The PHPFPM container must **mount the volume** at `/opcache-gui`, otherwise it will not work, and you will have a `404 file not found` error when browsing opcache-gui.

You can also notice that opcache-gui-share volume is mounted at `/app` in opcache-gui image.

In a docker-compose context, it's easier to refer to the PHPFPM container with its name : demo-phpfpm (this name is up to you, this one is in our example above). So during the build, the argument REMOTE_PHPFPM_HOST must be set to match this name.

```bash
DOCKER_BUILDKIT=1 docker build --build-arg REMOTE_PHPFPM_HOST=demo-phpfpm --build-arg REMOTE_PHPFPM_PORT=9000 -t opcache-gui .
```

