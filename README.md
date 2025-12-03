## go-wasi-http-example

This demonstrates how to implement a `wasi:http@0.3.0-rc-2025-09-16` handler
using Go, based on a new `wit-bindgen-go` bindings generator which supports
idiomatic, goroutine-based concurrency on top of the [Component Model
concurrency
ABI](https://github.com/WebAssembly/component-model/blob/main/design/mvp/Concurrency.md).

As of this writing, not everything has been upstreamed and released, so this
relies on Git submodules pointed at specific commits.  Once everything is
merged, we'll be able to switch to the upstream tools.

### Building and Running

#### Prerequisites

- Rust 1.91 or later
- Go 1.25.0 or later
- Make
- Curl

This will build the dependencies, generate Go bindings from the
`wasi:http@0.3.0-rc-2025-09-16` WIT files, build the component, and run it using
`wasmtime serve`:

```shell
make run
```

While that's running, you can send a request from another shell:

```
curl -i localhost:8080/hello
```

If all goes well, you should see `hello, world!`.
