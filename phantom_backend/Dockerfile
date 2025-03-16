FROM golang:1.24
LABEL authors="tomato"

WORKDIR /flutter/app/phantom_backend

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build .
CMD ["./phantom_backend"]