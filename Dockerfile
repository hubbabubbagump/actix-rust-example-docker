FROM rust:1.69.0 as chef
RUN cargo install cargo-chef
WORKDIR /usr/app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /usr/app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

COPY . .
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
