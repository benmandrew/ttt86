FROM alpine AS builder

RUN apk update && apk add nasm make binutils && rm -rf /var/cache/apk/*

COPY . .

RUN make all

FROM alpine

COPY --from=builder ./build/main ./main

CMD ["./main"]
