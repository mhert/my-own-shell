NAME = $(shell basename $(CURDIR))

TINI_VERSION = v0.14.0
GO_VERSION = 1.9.0

IMAGE_PATH = $(REGISTRY)/$(NAME):$(VERSION)

GO_NAME = my-own-shell
GO_BIN_NAME = my-own-shell

.PHONY: all build clean push

all: build

compile: clean
	mkdir -p build/bin
	cp -r src build
	docker run --rm \
	    -v /etc/passwd:/etc/passwd:ro \
	    -v $(CURDIR)/build:/build -w /build \
	    -e CGO_ENABLED=0 -e GOOS=linux -e GOARCH=amd64 \
	    -e GOPATH=/build \
	    -u $(shell id -u):$(shell id -g) \
	    golang:$(GO_VERSION) \
            go get -v -a -pkgdir /build/pkg -installsuffix cgo ./...

	docker run --rm \
	    -v /etc/passwd:/etc/passwd:ro \
	    -v $(CURDIR)/build:/build -w /build \
	    -e CGO_ENABLED=0 -e GOOS=linux -e GOARCH=amd64 \
	    -e GOPATH=/build \
	    -u $(shell id -u):$(shell id -g) \
	    golang:$(GO_VERSION) \
	        go build -v -a -pkgdir /build/pkg -installsuffix cgo -o bin/$(GO_BIN_NAME) $(GO_NAME)

build: clean compile
	wget -O build/bin/tini https://github.com/krallin/tini/releases/download/$(TINI_VERSION)/tini-static

clean:
	rm -rf build
