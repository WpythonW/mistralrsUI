# Mistral.rs Server Installation and Usage Guide

This guide provides instructions for installing, setting up, and running the Mistral.rs server with UI support.

## Prerequisites

- Python 3.x
- Rust programming language
- OpenSSL development libraries
- pkg-config (Linux only)
- NVIDIA GPU with CUDA support (for GPU acceleration)
- NVIDIA CUDA Toolkit 12.6
- Docker and Docker Compose
- NVIDIA Container Toolkit

## Installation Steps

### 1. Install Required Packages

#### Ubuntu/Debian:
```bash
sudo apt install libssl-dev pkg-config
```

### 2. Install NVIDIA CUDA Toolkit

Before proceeding, ensure you have the NVIDIA CUDA Toolkit 12.6 installed. Download and install it from the [NVIDIA CUDA Toolkit Archive](https://developer.nvidia.com/cuda-toolkit-archive).

### 3. Install Rust

Visit https://rustup.rs/ or run:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### 4. Install Mistral.rs Python Package

With the NVIDIA CUDA Toolkit installed, proceed with the Mistral.rs installation:

```bash
pip install mistralrs-cuda -v
```

For other hardware options:
- Metal: `pip install mistralrs-metal -v`
- Apple Accelerate: `pip install mistralrs-accelerate -v`
- Intel MKL: `pip install mistralrs-mkl -v`
- Without accelerators: `pip install mistralrs -v`

### 5. Build from Source

```bash
git clone https://github.com/EricLBuehler/mistral.rs.git
cd mistral.rs
cargo build --release
```

For specific features, add the appropriate flags:
- CUDA: `--features cuda`
- CUDA with Flash Attention V2: `--features "cuda flash-attn"`
- Metal: `--features metal`
- Accelerate: `--features accelerate`
- MKL: `--features mkl`

### 6. Install for Command Line Usage (Optional)

```bash
cargo install --path mistralrs-server --features <your-chosen-features>
```

### 7. Docker Setup for UI

1. Install Docker:

```bash
curl https://get.docker.com | sh
sudo systemctl --now enable docker
sudo usermod -aG docker $USER
```

2. Install NVIDIA Container Toolkit:

```bash
# Add NVIDIA Container Toolkit repository
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Update package list
sudo apt-get update

# Install NVIDIA Container Toolkit
sudo apt-get install -y nvidia-container-toolkit

# Configure Docker to use NVIDIA GPU
sudo nvidia-ctk runtime configure --runtime=docker

# Restart Docker
sudo systemctl restart docker
```

3. Prepare Docker files

Ensure you have the following files in your project directory:
   - `model.Dockerfile`
   - `ui.Dockerfile`
   - `docker-compose.yml`
   - `app.py` (for the UI)

4. Build and run the containers:

```bash
docker-compose up -d
```

This command builds the containers for both the model server and the UI, and starts them in detached mode.

## Usage

### Running the Server

To run the Mistral.rs server, use the following command:

```bash
./mistralrs-server -p 1234 --isq Q4K -i plain --model-id microsoft/Phi-3-mini-128k-instruct --arch phi3
```

This command starts the server on port 1234 using the Phi-3-mini-128k-instruct model with the phi3 architecture.

## Running Services and Ports

After successful installation and launch, the following services will be available:

1. Mistral.rs Server (model):
   - Port: 1234
   - URL: http://localhost:1234
   - Description: The main Mistral.rs server that handles model requests.

2. UI (user interface):
   - Port: 7860
   - URL: http://localhost:7860
   - Description: Web interface for interacting with the Mistral.rs server.

To access these services:
- For direct interaction with the model API, use: http://localhost:1234
- To access the web interface, open in your browser: http://localhost:7860

Note: If you're running these services on a remote server, replace "localhost" with your server's IP address or domain name.

## Additional Resources

For more detailed information on running Docker containers, refer to the official Docker documentation: https://docs.docker.com/engine/reference/run/

For advanced usage of the Mistral.rs server in your projects, consult the API documentation and integration guides.
