FROM rust:1.88-slim AS builder

WORKDIR /repo
RUN apt-get update \
    && apt-get install -y --no-install-recommends pkg-config libssl-dev ca-certificates g++ curl git \
    && rm -rf /var/lib/apt/lists/*

COPY packages/migration-claim/sp1 ./packages/migration-claim/sp1

# Install SP1 toolchain and build guest ELF before compiling the host API.
ENV PATH="/root/.sp1/bin:${PATH}"
RUN curl -L https://sp1up.succinct.xyz | bash \
    && /root/.sp1/bin/sp1up

WORKDIR /repo/packages/migration-claim/sp1/program
RUN cargo prove build \
    && mkdir -p elf \
    && cp "$(find ../target/elf-compilation -type f -name sr25519-claim-program | head -n1)" elf/riscv32im-succinct-zkvm-elf

WORKDIR /repo/packages/migration-claim/sp1
RUN cargo build -p tnt-claim-prover-api --release

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Create app directory structure
WORKDIR /app

# Copy eligibility data (can be overridden via volume mount at runtime)
COPY packages/migration-claim/sp1/merkle-tree.json /app/data/merkle-tree.json

# Copy binary
COPY --from=builder /repo/packages/migration-claim/sp1/target/release/tnt-claim-prover-api /usr/local/bin/tnt-claim-prover-api

# Set default eligibility path (overridable via ELIGIBILITY_FILE env var)
ENV ELIGIBILITY_FILE=/app/data/merkle-tree.json
ENV PORT=8080
EXPOSE 8080

CMD ["tnt-claim-prover-api"]
