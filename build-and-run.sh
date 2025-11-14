#!/bin/bash

# Build and Run Claude Code Docker Container with Customizations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
IMAGE_NAME="claude-code-customized"
CONTAINER_NAME="claude-code-customized"
COMPOSE_FILE="docker-compose.yml"

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        exit 1
    fi

    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "Docker Compose is not installed or not in PATH"
        exit 1
    fi

    # Check if .env file exists
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            log_warning ".env file not found. Creating from .env.example..."
            cp .env.example .env
            log_warning "Please edit .env file and set your ANTHROPIC_AUTH_TOKEN"
            exit 1
        else
            log_error ".env file not found and no .env.example available"
            exit 1
        fi
    fi

    # Check if ANTHROPIC_AUTH_TOKEN is set
    if ! grep -q "ANTHROPIC_AUTH_TOKEN=your_anthropic_api_token_here" .env && \
       grep -q "^ANTHROPIC_AUTH_TOKEN=" .env; then
        log_success "ANTHROPIC_AUTH_TOKEN appears to be configured"
    else
        log_error "ANTHROPIC_AUTH_TOKEN is not properly configured in .env file"
        exit 1
    fi

    log_success "Prerequisites check passed"
}

# Build Docker image
build_image() {
    log_info "Building Docker image: $IMAGE_NAME"

    if command -v docker-compose &> /dev/null; then
        docker-compose build
    else
        docker compose build
    fi

    log_success "Docker image built successfully"
}

# Run container
run_container() {
    log_info "Starting container: $CONTAINER_NAME"

    # Stop and remove existing container if it exists
    if docker ps -a --format 'table {{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        log_warning "Container $CONTAINER_NAME already exists. Stopping and removing..."
        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        docker rm "$CONTAINER_NAME" 2>/dev/null || true
    fi

    # Start new container
    if command -v docker-compose &> /dev/null; then
        docker-compose up -d
    else
        docker compose up -d
    fi

    log_success "Container started successfully"
}

# Show container status and usage
show_status() {
    log_info "Container status:"
    docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

    echo
    log_info "Customizations applied:"
    echo "  ✓ Auto-compact buffer reduced to 5%"
    echo "  ✓ Markdown-based customization symlinks created"
    echo "  ✓ Projects directory ready for drop-in customizations"
    echo
    log_info "To use Claude Code:"
    echo "  docker exec -it $CONTAINER_NAME claude"
    echo
    log_info "To add customizations:"
    echo "  Skills: docker exec -it $CONTAINER_NAME bash -c 'echo \"# My Skill\" > ~/projects/claude-skills/my-skill.md'"
    echo "  Commands: docker exec -it $CONTAINER_NAME bash -c 'echo \"# My Command\" > ~/projects/claude-commands/my-command.md'"
    echo
    log_info "To check context usage:"
    echo "  docker exec -it $CONTAINER_NAME claude"
    echo "  Then run: /context"
}

# Show logs
show_logs() {
    log_info "Showing container logs:"
    if command -v docker-compose &> /dev/null; then
        docker-compose logs -f
    else
        docker compose logs -f
    fi
}

# Stop container
stop_container() {
    log_info "Stopping container: $CONTAINER_NAME"

    if command -v docker-compose &> /dev/null; then
        docker-compose down
    else
        docker compose down
    fi

    log_success "Container stopped"
}

# Main function
main() {
    case "${1:-build-and-run}" in
        "build"|"b")
            check_prerequisites
            build_image
            ;;
        "run"|"r")
            check_prerequisites
            run_container
            show_status
            ;;
        "build-and-run"|"br")
            check_prerequisites
            build_image
            run_container
            show_status
            ;;
        "logs"|"l")
            show_logs
            ;;
        "stop"|"s")
            stop_container
            ;;
        "status"|"st")
            show_status
            ;;
        "help"|"h"|"-h"|"--help")
            echo "Usage: $0 [command]"
            echo
            echo "Commands:"
            echo "  build-and-run (br)  Build image and run container (default)"
            echo "  build (b)           Build Docker image only"
            echo "  run (r)             Run container only"
            echo "  logs (l)            Show container logs"
            echo "  stop (s)            Stop and remove container"
            echo "  status (st)         Show container status"
            echo "  help (h)            Show this help"
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"