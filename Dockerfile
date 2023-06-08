FROM rust:1.69.0 as builder
RUN cargo install cargo-chef
WORKDIR /usr/app

RUN mkdir -p /usr/app/src
COPY Cargo.toml Cargo.lock /usr/app/

RUN \
    echo 'fn main() {}' > /usr/app/src/main.rs && \
    cargo build -p $SERVICE --release && \
    rm -Rvf /usr/app/src

COPY src /usr/app/src
RUN cargo build --release

FROM debian:bullseye-slim
WORKDIR /app

# copy server binary from build stage
COPY --from=builder /usr/app/target/release/docker_sample docker_sample

# set user to non-root unless root is required for your app
USER 1001

# indicate what port the server is running on
EXPOSE 8080

# run server
CMD [ "/usr/app/docker_sample" ]
