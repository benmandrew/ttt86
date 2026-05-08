# TTT86

![Coverage](docs/coverage.svg) [![Docker Image Size](https://img.shields.io/docker/image-size/benmandrew/ttt86)](https://hub.docker.com/repository/docker/benmandrew/ttt86/general)

Tic-Tac-Toe in 64-bit x86 NASM assembly.

Run from Docker with

```sh
$ docker run -it benmandrew/ttt86
```

Alternatively, build and run on Linux with

```sh
$ make
$ ./build/main
```

## Tools

**Build** (`make`, `make run`)

| Tool | Purpose |
|------|---------|
| `nasm` | Assembles `.s` source files |
| `ld` (binutils) | Links object files into a static binary |

**Dev** (`make test`, `make coverage`, `make fmt`)

| Tool | Purpose |
|------|---------|
| `expect` | Drives the TTY-based integration tests |
| `valgrind` (callgrind) | Instruments the binary to record per-line execution counts |
| `callgrind_annotate` (valgrind) | Renders the annotated source coverage report |
| `objdump` (binutils) | Reads DWARF debug info to enumerate executable lines |
| `bc` | Computes the coverage percentage in `docs/coverage.sh` |
| `nasfmt` | Formats `.s` source files (`make fmt`) |
