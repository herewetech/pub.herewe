PROJECT=herewe::pub.herewe
PREFIX=$(shell pwd)
VERSION=$(shell git describe --match 'v[0-9]*'  --always)
DEFAULT_BRANCH=$(shell git symbolic-ref --short -q HEAD)

ifndef OS
	OS=linux
	unameOut=$(shell uname -s)
	ifeq ($(unameOut),Darwin)
		OS=darwin
	endif

	ifeq ($(OSTYPE),win32)
		OS=windows
	endif
endif

ifndef ARCH
	ARCH=amd64
	unameOut=$(shell uname -m)
	ifeq ($(unameOut),i386)
		ARCH=386
	endif

	ifeq ($(unameOut),i686)
		ARCH=386
	endif
endif

ifndef BRANCH
	BRANCH=$(DEFAULT_BRANCH)
endif

ifdef CI_COMMIT_REF_SLUG
	BRANCH=$(CI_COMMIT_REF_SLUG)
endif

ifndef DEPLOY_REPLICA
	DEPLOY_REPLICA=1
endif

ifndef GO
	GO=go
endif

ifndef GOFMT
	GOFMT=gofmt
endif

ifndef PROTOC
	PROTOC=protoc
endif

ifndef GIT
	GIT=git
endif

ifndef SWAG
	SWAG=swag
endif

ifndef DOCKER
	DOCKER=docker
endif

PROTO_DIR=./proto
DOC_DIR=./doc

.PHONY: all summary build doc
.DEFAULT: all

PROTOS=$(shell ls proto/*.proto)

# Targets
all: summary build doc

summary:
	@printf "\033[1;37m  == \033[1;32m$(PROJECT) \033[1;33m$(VERSION) \033[1;37m==\033[0m\n"
	@printf "    Platform    : \033[1;37m$(shell uname -sr)\033[0m\n"
	@printf "    Target OS   : \033[1;37m$(OS)\033[0m\n"
	@printf "    Target Arch : \033[1;37m$(ARCH)\033[0m\n"
	@printf "    Branch      : \033[1;37m$(BRANCH)\033[0m\n"
	@echo

build:
	@printf "\033[1;36m  Compiling protobuf ...\033[0m\n"
	@for f in $(PROTOS); do \
		printf "    \033[1;34mTarget : \033[1;35m$$f\033[0m\n" ; \
		$(PROTOC) -I $(PROTO_DIR) --go_out=. --go-grpc_out=. $$f ; \
	done
	@echo

doc:
	@printf "\033[1;36m  Generate protobuf docs ...\033[0m\n"
	@mkdir -p $(DOC_DIR)
	@for f in $(PROTOS); do \
		printf "    \033[1;34mTarget : \033[1;35m$$f\033[0m\n" ; \
		$(PROTOC) -I $(PROTO_DIR) --doc_out=./doc --doc_opt=markdown,$$f.md $$f ; \
	done
	@echo
