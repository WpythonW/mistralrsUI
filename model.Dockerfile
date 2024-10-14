# Этап сборки
FROM nvidia/cuda:12.6.1-devel-ubuntu24.04 AS builder

# Установка необходимых зависимостей для сборки
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Установка Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup update stable && rustup default stable

# Копирование и сборка проекта
WORKDIR /mistralrs
COPY . .
ARG CUDA_COMPUTE_CAP=75
ENV CUDA_COMPUTE_CAP=${CUDA_COMPUTE_CAP}
ARG FEATURES="cuda"
ENV RAYON_NUM_THREADS=4
RUN cargo build --release --workspace --exclude mistralrs-pyo3 --features "${FEATURES}"

# Этап выполнения
FROM nvidia/cuda:12.6.1-runtime-ubuntu24.04

# Настройка переменных окружения
ENV HUGGINGFACE_HUB_CACHE=/data \
    PORT=1234 \
    RAYON_NUM_THREADS=8 \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Установка необходимых зависимостей для выполнения
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libomp-dev \
    ca-certificates \
    libssl-dev \
    curl \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Копирование собранных бинарных файлов из этапа сборки
COPY --from=builder /mistralrs/target/release/mistralrs-server /usr/local/bin/mistralrs-server
RUN chmod +x /usr/local/bin/mistralrs-server

# Запуск сервера
ENTRYPOINT ["mistralrs-server", "--port", "1234", "plain", "--model-id", "microsoft/Phi-3-mini-128k-instruct", "--arch", "phi3"]