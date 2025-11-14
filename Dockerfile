# ---- Stage 1: The "Builder" ----
# We start with an official Go image, which has the Go compiler and all build tools.
# We'll name this stage "builder" so we can refer to it later.
FROM golang:1.25-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files to download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of your application's source code
COPY . .

# HERE IS THE ANSWER: Run the `go build` command.
# This compiles the source code into a single binary named 'my-api-server'.
# The flags are important:
# - CGO_ENABLED=0: Disables Cgo, creating a purely static Go binary. This is more portable.
# - -o /app/my-api-server: Specifies the output path and name of the binary.
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/my-api-server .


# ---- Stage 2: The "Final" Image ----
# Now, we start fresh with a new, incredibly small base image.
# 'scratch' is an empty image, but alpine is better as it has SSL certs.
FROM alpine:latest

# Set the working directory
WORKDIR /app

# The MAGIC STEP:
# Copy ONLY the compiled binary from the "builder" stage into this final image.
# The source code and the entire Go compiler from Stage 1 are thrown away.
COPY --from=builder /app/my-api-server .

# Expose the port that the application will run on
EXPOSE 8080

# The command to run when a container is started from this image.
# It simply executes our compiled binary.
CMD ["./my-api-server"]