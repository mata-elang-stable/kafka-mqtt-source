FROM golang:1.19-alpine AS build

ARG TARGETARCH
ARG TARGETOS

RUN apk add --no-cache librdkafka-dev pkgconf build-base musl-dev

WORKDIR /app

COPY go.mod /app/
COPY go.sum /app/

RUN go mod download

COPY . /app/

RUN GOOS=linux GOARCH=${BUILDPLATFORM} GO111MODULE=on CGO_ENABLED=1 go build -tags dynamic -tags musl -o me-mqtt-source ./cmd/

FROM golang:1.19-alpine

RUN apk add --no-cache librdkafka

COPY --from=build /app/me-mqtt-source /app/me-mqtt-source

ENTRYPOINT [ "/app/me-mqtt-source" ]
CMD [ "-b" ]
