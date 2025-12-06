handler.wasm: handler-with-wit.wasm wasi_snapshot_preview1.reactor.wasm bin/wasm-tools
	bin/wasm-tools component new --adapt wasi_snapshot_preview1.reactor.wasm $< --output $@

handler-with-wit.wasm: handler-module.wasm bin/wasm-tools
	bin/wasm-tools component embed wit $< --output $@

handler-module.wasm: export_wasi_http_handler/handler.go go/bin/go go.mod
	GOOS=wasip1 GOARCH=wasm go/bin/go build -o $@ -buildmode=c-shared -ldflags=-checklinkname=0 .

go.mod: bin/wit-bindgen
	$< go --out-dir . wit

wasi_snapshot_preview1.reactor.wasm:
	curl -OL https://github.com/bytecodealliance/wasmtime/releases/download/v39.0.1/wasi_snapshot_preview1.reactor.wasm

go/bin/go:
	git submodule update --init --recursive
	(cd go/src && bash make.bash)

bin/wit-bindgen:
	cargo install --locked --no-default-features --features go \
		--git https://github.com/bytecodealliance/wit-bindgen --rev 4284ea88 --root .

bin/wasmtime:
	cargo install --locked --git https://github.com/bytecodealliance/wasmtime --rev 54826c0e --root . wasmtime-cli

bin/wasm-tools:
	cargo install --locked wasm-tools --version 1.243.0 --root .

.PHONY: run
run: handler.wasm bin/wasmtime
	bin/wasmtime serve -Sp3,cli -Wcomponent-model-async $<
