FROM alpine

RUN apk update && apk add nasm make binutils && rm -rf /var/cache/apk/*

COPY . .

RUN make all

CMD ["./build/main"]
