FROM golang:1.26-trixie AS builder

WORKDIR /src
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/crash-app ./main.go

FROM gcr.io/distroless/static-debian13
COPY --from=builder /app/crash-app /app/crash-app
EXPOSE 8080
ENTRYPOINT ["/app/crash-app"]
