NAME=$(shell sed 's/[\", ]//g' package.json | grep name | cut -d: -f2 | head -1)
DESC=$(shell sed 's/[\",]//g' package.json | grep description | cut -d: -f2 | sed -e 's/^[ \t]*//')
VERSION=$(shell sed 's/[\", ]//g' package.json | grep version | cut -d: -f2)
PACKER=https://github.com/leonardothibes/packer-mirror/raw/master/bin/packer-1.9.1
IMAGE=${NAME}-${VERSION}

build: .clear install
	@[ -d build ] || mkdir build
	@rm -Rf build/${IMAGE} src/output-qemu
	@cd src ; ../bin/packer build template.json
	@mv src/output-qemu/packer-qemu build/${IMAGE}

launch: .clear
	@multipass launch file://${PWD}/build/${IMAGE} -n ${NAME}
	@multipass ls
	@echo ""
	@multipass shell ${NAME}

stop:
	@multipass delete ${NAME}
	@multipass purge

install: .clear
	@[ -d bin ]        || mkdir bin
	@[ -f bin/packer ] || wget ${PACKER} -O ./bin/packer
	@chmod 755 ./bin/*

clean:
	@rm -Rf build dist src/output-qemu

reset: clean
	@rm -Rf bin src/packer_cache

.clear:
	@clear

help: .clear
	@echo "${DESC} (${NAME} - ${VERSION})"
	@echo "Uso: make [options]"
	@echo ""
	@echo "  build (default)    Build da imagem"
	@echo "  launch             Lança um VM no Multipass com a imagem do build"
	@echo "  stop               Para a VM no Multipass"
	@echo ""
	@echo "  install            Instala as dependências"
	@echo "  clean              Apaga as os arquivos de build"
	@echo "  reset              Retorna o projeto ao seu estado original"
	@echo ""
	@echo "  help               Exibe esta mensagem de HELP"
	@echo ""

.PHONY: build
