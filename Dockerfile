FROM alpine:3.24 AS builder

RUN apk add --no-cache nasm make binutils

# Explicit build root. Without a WORKDIR the source landed in / and the binary came
# out at /build/main by accident of that default; naming it here keeps the COPY
# below pointing at a path this file actually sets.
WORKDIR /src

COPY . .

RUN make all

FROM scratch

COPY --from=builder /src/build/main /main

# Runs unprivileged. scratch has no /etc/passwd, so this is the numeric nobody
# uid:gid — the binary is static and mode 755, so it needs no account to resolve.
USER 65534:65534

CMD ["/main"]
