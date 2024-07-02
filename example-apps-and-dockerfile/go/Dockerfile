# Use the official Golang image to build the Go application
FROM golang:1.20 as builder

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files first to cache dependencies
COPY go.mod ./
COPY go.sum ./

# Download dependencies
RUN go mod download

# Copy the Go application source code to the container
COPY . .

# Build the Go application
RUN go build -o main .

# Use a minimal base image to run the Go application
FROM debian:latest

# Set the working directory inside the container
WORKDIR /root/

# Copy the built Go application from the builder stage to the runtime stage
COPY --from=builder /app/main .

# Ensure the main binary is executable
RUN chmod +x main

# Expose port 80 to the outside world
EXPOSE 80

# Run the Go application
CMD ["./main"]
