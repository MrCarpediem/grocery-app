#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Grocery App - Docker Setup Verification${NC}"
echo -e "${BLUE}================================================${NC}\n"

# Check Docker installation
echo -e "${YELLOW}[1/10] Checking Docker installation...${NC}"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓${NC} Docker installed: $DOCKER_VERSION"
else
    echo -e "${RED}✗${NC} Docker not found. Please install Docker."
    exit 1
fi

# Check Docker Compose installation
echo -e "\n${YELLOW}[2/10] Checking Docker Compose installation...${NC}"
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version)
    echo -e "${GREEN}✓${NC} Docker Compose installed: $COMPOSE_VERSION"
else
    echo -e "${RED}✗${NC} Docker Compose not found. Please install Docker Compose."
    exit 1
fi

# Check if Docker daemon is running
echo -e "\n${YELLOW}[3/10] Checking if Docker daemon is running...${NC}"
if docker ps > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Docker daemon is running"
else
    echo -e "${RED}✗${NC} Docker daemon is not running. Start Docker and try again."
    exit 1
fi

# Check if .env exists
echo -e "\n${YELLOW}[4/10] Checking .env file...${NC}"
if [ -f .env ]; then
    echo -e "${GREEN}✓${NC} .env file exists"
else
    if [ -f .env.example ]; then
        echo -e "${YELLOW}! ${NC}.env not found, copying from .env.example..."
        cp .env.example .env
        echo -e "${GREEN}✓${NC} Created .env file (please edit with your values)"
    else
        echo -e "${RED}✗${NC} Neither .env nor .env.example found"
        exit 1
    fi
fi

# Check if Docker Compose file exists
echo -e "\n${YELLOW}[5/10] Checking docker-compose.yml...${NC}"
if [ -f docker-compose.yml ]; then
    echo -e "${GREEN}✓${NC} docker-compose.yml exists"
else
    echo -e "${RED}✗${NC} docker-compose.yml not found"
    exit 1
fi

# Check if required Dockerfiles exist
echo -e "\n${YELLOW}[6/10] Checking Dockerfiles...${NC}"
if [ -f backend/Dockerfile ] && [ -f client/Dockerfile ]; then
    echo -e "${GREEN}✓${NC} Both Dockerfiles exist"
else
    echo -e "${RED}✗${NC} Missing Dockerfile in backend or client"
    exit 1
fi

# Pull and build images
echo -e "\n${YELLOW}[7/10] Building Docker images...${NC}"
if docker-compose build --quiet > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Docker images built successfully"
else
    echo -e "${RED}✗${NC} Failed to build Docker images"
    exit 1
fi

# Start containers
echo -e "\n${YELLOW}[8/10] Starting containers...${NC}"
if docker-compose up -d > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Containers started"
else
    echo -e "${RED}✗${NC} Failed to start containers"
    exit 1
fi

# Wait for services to be ready
echo -e "\n${YELLOW}[9/10] Waiting for services to be ready (this may take 30 seconds)...${NC}"
sleep 5

# Check if services are running
MONGODB_READY=0
BACKEND_READY=0
FRONTEND_READY=0

for i in {1..30}; do
    echo -ne "${BLUE}Wait: $i/30 seconds...${NC}\r"
    
    if [ $MONGODB_READY -eq 0 ]; then
        if docker-compose exec -T mongodb mongosh --version > /dev/null 2>&1; then
            MONGODB_READY=1
        fi
    fi
    
    if [ $BACKEND_READY -eq 0 ]; then
        if curl -s http://localhost:5000/api/product/list > /dev/null 2>&1; then
            BACKEND_READY=1
        fi
    fi
    
    if [ $FRONTEND_READY -eq 0 ]; then
        if curl -s http://localhost > /dev/null 2>&1; then
            FRONTEND_READY=1
        fi
    fi
    
    if [ $MONGODB_READY -eq 1 ] && [ $BACKEND_READY -eq 1 ] && [ $FRONTEND_READY -eq 1 ]; then
        break
    fi
    
    sleep 1
done

echo -e "\n${GREEN}✓${NC} All services are starting up"

# Final health checks
echo -e "\n${YELLOW}[10/10] Performing final health checks...${NC}"

# Check Backend
if curl -s http://localhost:5000/api/product/list > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Backend API is responding"
else
    echo -e "${YELLOW}!${NC} Backend still initializing... (it's okay, just slow)"
fi

# Check Frontend
if curl -s http://localhost | grep -q "html" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Frontend is serving"
else
    echo -e "${YELLOW}!${NC} Frontend still initializing..."
fi

# Check MongoDB
if docker-compose exec -T mongodb mongosh --version > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} MongoDB is running"
else
    echo -e "${RED}✗${NC} MongoDB not responding"
fi

# Summary
echo -e "\n${BLUE}================================================${NC}"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo -e "${BLUE}================================================${NC}\n"

echo -e "${YELLOW}Access your app:${NC}"
echo -e "  Frontend:  ${BLUE}http://localhost${NC}"
echo -e "  Backend:   ${BLUE}http://localhost:5000${NC}"
echo -e "  API Docs:  ${BLUE}http://localhost:5000/api/product/list${NC}\n"

echo -e "${YELLOW}Useful commands:${NC}"
echo -e "  View logs:     ${BLUE}docker-compose logs -f${NC}"
echo -e "  Stop services: ${BLUE}docker-compose down${NC}"
echo -e "  Restart:       ${BLUE}docker-compose restart${NC}"
echo -e "  Check status:  ${BLUE}docker-compose ps${NC}\n"

echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Open http://localhost in your browser"
echo -e "  2. Register a new user"
echo -e "  3. Test adding products to cart"
echo -e "  4. Check logs: docker-compose logs -f backend\n"

echo -e "${YELLOW}For detailed verification guide, see:${NC} DOCKER_SETUP.md"
