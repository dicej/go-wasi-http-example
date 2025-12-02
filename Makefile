handler.wasm: handler-with-wit.wasm wasi_snapshot_preview1.reactor.wasm wasm-tools/target/release/wasm-tools
	wasm-tools/target/release/wasm-tools component new --adapt wasi_snapshot_preview1.reactor.wasm $< --output $@

handler-with-wit.wasm: handler-module.wasm wasm-tools/target/release/wasm-tools
	wasm-tools/target/release/wasm-tools component embed wit $< --output $@

handler-module.wasm: export_wasi_http_handler/handler.go go/bin/go go.mod
	GOOS=wasip1 GOARCH=wasm go/bin/go build -o $@ -buildmode=c-shared -ldflags=-checklinkname=0 .

go.mod: wit-bindgen/target/release/wit-bindgen
	$< go --out-dir . wit

wasi_snapshot_preview1.reactor.wasm:
	curl -OL https://github.com/bytecodealliance/wasmtime/releases/download/v39.0.1/wasi_snapshot_preview1.reactor.wasm

go/bin/go:
	git submodule update --init --recursive
	(cd go/src && bash make.bash)

wit-bindgen/target/release/wit-bindgen:
	git submodule update --init --recursive
	(cd wit-bindgen && cargo build --release --no-default-features --features go)

wasmtime/target/release/wasmtime:
	git submodule update --init --recursive
	(cd wasmtime && cargo build --release)

wasm-tools/target/release/wasm-tools:
	git submodule update --init --recursive
	(cd wasm-tools && cargo build --release)

.PHONY: run
run: handler.wasm wasmtime/target/release/wasmtime
	wasmtime/target/release/wasmtime serve -Sp3,cli -Wcomponent-model-async $<
