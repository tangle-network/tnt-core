FROM rust:1.85-slim AS builder

WORKDIR /repo
RUN apt-get update \
    && apt-get install -y --no-install-recommends pkg-config libssl-dev ca-certificates g++ \
    && rm -rf /var/lib/apt/lists/*

COPY packages/migration-claim/sp1 ./packages/migration-claim/sp1

WORKDIR /repo/packages/migration-claim/sp1
RUN cargo build -p tnt-claim-prover-api --release

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates libssl3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /repo/packages/migration-claim/sp1/target/release/tnt-claim-prover-api /usr/local/bin/tnt-claim-prover-api

ENV PORT=8080
EXPOSE 8080

CMD ["tnt-claim-prover-api"]
