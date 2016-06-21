# Docker image to provide Lime text editor
# Build with
#   docker build --force-rm -t brunetto/docker-lime .

FROM ubuntu:16.04
MAINTAINER Brunetto Ziosi <brunetto.ziosi@gmail.com>

#RUN set -euo pipefail

# Set the required environment variables.
ENV GOPATH $HOME/golang
ENV PKG_CONFIG_PATH $GOPATH/src/github.com/limetext/rubex
ENV GODEBUG 0
ENV cgocheck 0 # Required for the code to work with Go 1.6.

# Set up the backend.
RUN apt-get update --quiet && apt-get -y install git golang libonig-dev \
 libonig2 mercurial python3.5 python3.5-dev && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


RUN go get github.com/limetext/backend \
    && cd $GOPATH/src/github.com/limetext/backend \
    && git submodule update --init --recursive \
    && go test github.com/limetext/backend/...

# Set up the QML frontend.
RUN apt-get update --quiet && apt-get install --yes \
    libqt5opengl5-dev libqt5qml-graphicaleffects qtbase5-private-dev \
    qtdeclarative5-controls-plugin qtdeclarative5-dev \
    qtdeclarative5-dialogs-plugin qtdeclarative5-qtquick2-plugin \
    qtdeclarative5-quicklayouts-plugin qtdeclarative5-window-plugin

RUN go get github.com/limetext/lime-qml/main/... \
    && cd $GOPATH/src/github.com/limetext/lime-qml \
    && git submodule update --init --recursive

# Build the QML frontend.
RUN cd $GOPATH/src/github.com/limetext/lime-qml/main && go build

ENTRYPOINT ["/golang/src/github.com/limetext/lime-qml/main/main"]
#ENTRYPOINT ["/bin/bash"]
