# build image
FROM golang:1.19 AS build

WORKDIR /app

ENV GO111MODULE=on

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -o app

# release image
FROM gcr.io/distroless/static

COPY --from=build /app/app /
EXPOSE 8080

CMD ["/app"]
