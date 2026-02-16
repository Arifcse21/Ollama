terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6"
    }
  }
}

provider "docker" {}

# Create a shared Docker network
resource "docker_network" "ollama_net" {
  name   = "ollama-network"
  driver = "bridge"
}

# Persistent volume for Ollama models
resource "docker_volume" "ollama_data" {
  name = "ollama_data"
  lifecycle {
    prevent_destroy = true
  }
}

# Persistent volume for Open WebUI
resource "docker_volume" "open_webui_data" {
  name = "open_webui_data"
}

# Ollama container (8 GB RAM limit)
resource "docker_container" "ollama" {
  name  = "ollama"
  image = "ollama/ollama:latest"
  # gpus = "all"
  # cpu_set = 2

  ports {
    external = 11434
    internal = 11434
  }

  env = [
    "OLLAMA_HOST=0.0.0.0",
    "OLLAMA_ORIGINS=*",
    "OLLAMA_SCHED_SPREAD=false", # Keep models tight
    "OLLAMA_MAX_LOADED_MODELS=3",  # Force one model at a time for low VRAM
    "OLLAMA_NUM_PARALLEL=3",
    "OLLAMA_KEEP_ALIVE=15m",   # Don't hog VRAM forever
    "OLLAMA_NOPRUNE=true"     # Keep the model cached
  ]

  networks_advanced {
    name = docker_network.ollama_net.name
  }

  volumes {
    volume_name    = docker_volume.ollama_data.name
    container_path = "/root/.ollama"
  }

  # Limit memory to 8 GB
  # memory = 8589934592
  memory = 10737418240 # 10 GB

  restart = "unless-stopped"
}

# Open WebUI container (2 GB RAM limit)
resource "docker_container" "open_webui" {
  name  = "open-webui"
  image = "ghcr.io/open-webui/open-webui:main"

  networks_advanced {
    name = docker_network.ollama_net.name
  }

  volumes {
    volume_name    = docker_volume.open_webui_data.name
    container_path = "/app/backend/data"
  }

  env = [
    "OLLAMA_BASE_URL=http://ollama:11434",
    "WEBUI_HOST=0.0.0.0",
    "WEBUI_PORT=8080"
  ]

  ports {
    internal = 8080
    external = 3000
  }

  # Limit memory to 2 GB
  memory = 2147483648

  restart = "unless-stopped"
  depends_on = [docker_container.ollama]
}