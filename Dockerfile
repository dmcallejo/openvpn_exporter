# syntax=docker/dockerfile:1
# BUILD STAGE
FROM golang:alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

# cache deps
COPY go.mod go.sum ./
RUN go mod download

# copy and compile
COPY . .
RUN CGO_ENABLED=0 GOOS=linux \
    go build -ldflags="-s -w" -o openvpn_exporter .

# RUNTIME STAGE
FROM alpine AS runtime

# bash is needed by the entrypoint.sh
RUN apk add --no-cache bash ca-certificates

# copy the Go binary
COPY --from=builder /app/openvpn_exporter /bin/openvpn_exporter

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["-h"]
