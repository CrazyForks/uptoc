.PHONY: default install build fmt test vet docker clean


PROJECT=uptoc
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))

TARGET_DIR=${MKFILE_DIR}build
TARGET_PREFIX=${TARGET_DIR}/${PROJECT}

TARGZ_DIR=${TARGET_DIR}/targz
TARGZ_PREFIX=${TARGZ_DIR}/${PROJECT}

LDFLAGS="-s -w -X ${BINARY}/version.release=${RELEASE} -X ${BINARY}/version.commit=${COMMIT} -X ${BINARY}/version.repo=${GITREPO}"

# git info
COMMIT := git-$(shell git rev-parse --short HEAD)
GITREPO := $(shell git config --get remote.origin.url)
RELEASE := $(shell git describe --tags | awk -F '-' '{print $$1}')

default: install build

install:
	go mod download

build:
	CGO_ENABLED=0 GOOS=linux GOARCH=386 go build -ldflags ${LDFLAGS} -o ${TARGET_PREFIX}-linux-386/${PROJECT}
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags ${LDFLAGS} -o ${TARGET_PREFIX}-linux-amd64/${PROJECT}
	CGO_ENABLED=0 GOOS=darwin GOARCH=386 go build -ldflags ${LDFLAGS} -o ${TARGET_PREFIX}-darwin-386/${PROJECT}
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -ldflags ${LDFLAGS} -o ${TARGET_PREFIX}-darwin-amd64/${PROJECT}
	CGO_ENABLED=0 GOOS=windows GOARCH=386 go build -ldflags ${LDFLAGS} -o ${TARGET_PREFIX}-windows-386/${PROJECT}
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -ldflags ${LDFLAGS} -o ${TARGET_PREFIX}-windows-amd64/${PROJECT}

test:
	go test -coverprofile=coverage.txt -covermode=atomic ./...
    go tool cover --func=coverage.txt

covhtml:
	go tool cover -html=coverage.txt

pack:
	mkdir -p ${TARGZ_DIR}
	tar -C ${TARGET_DIR} -zvcf ${TARGZ_PREFIX}-linux-386.tar.gz ${PROJECT}-linux-386/${PROJECT}
	tar -C ${TARGET_DIR} -zvcf ${TARGZ_PREFIX}-linux-amd64.tar.gz ${PROJECT}-linux-amd64/${PROJECT}
	tar -C ${TARGET_DIR} -zvcf ${TARGZ_PREFIX}-darwin-386.tar.gz ${PROJECT}-darwin-386/${PROJECT}
	tar -C ${TARGET_DIR} -zvcf ${TARGZ_PREFIX}-darwin-amd64.tar.gz ${PROJECT}-darwin-amd64/${PROJECT}
	tar -C ${TARGET_DIR} -zvcf ${TARGZ_PREFIX}-windows-386.tar.gz ${PROJECT}-windows-386/${PROJECT}
	tar -C ${TARGET_DIR} -zvcf ${TARGZ_PREFIX}-windows-amd64.tar.gz ${PROJECT}-windows-amd64/${PROJECT}

clean:
	rm -rf ${TARGET_DIR}