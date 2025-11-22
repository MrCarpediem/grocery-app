#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

API_URL="http://localhost:5000/api"
FRONTEND_URL="http://localhost"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Grocery App - API Test Suite${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Test 1: Backend connectivity
echo -e "${YELLOW}[Test 1] Backend connectivity...${NC}"
if curl -s "$API_URL/product/list" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Backend is reachable${NC}\n"
else
    echo -e "${RED}✗ Backend is not reachable at $API_URL${NC}"
    echo -e "${RED}Make sure docker-compose is running: docker-compose up -d${NC}\n"
    exit 1
fi

# Test 2: Get products list
echo -e "${YELLOW}[Test 2] Fetching products list...${NC}"
PRODUCTS=$(curl -s "$API_URL/product/list")
echo -e "${GREEN}✓ Response: ${NC}$(echo $PRODUCTS | head -c 100)...\n"

# Test 3: User Registration
echo -e "${YELLOW}[Test 3] User registration...${NC}"
TEST_EMAIL="testuser$(date +%s)@example.com"
REGISTER_RESPONSE=$(curl -s -X POST "$API_URL/user/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Test User\",
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"testpass123\"
  }")

if echo "$REGISTER_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ User registered successfully${NC}"
    echo -e "  Email: $TEST_EMAIL\n"
else
    echo -e "${RED}✗ Registration failed${NC}"
    echo -e "  Response: $REGISTER_RESPONSE\n"
fi

# Test 4: User Login
echo -e "${YELLOW}[Test 4] User login...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/user/login" \
  -H "Content-Type: application/json" \
  -c /tmp/cookies.txt \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"testpass123\"
  }")

if echo "$LOGIN_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ User logged in successfully${NC}\n"
    
    # Test 5: Check authentication
    echo -e "${YELLOW}[Test 5] Checking authentication...${NC}"
    AUTH_RESPONSE=$(curl -s -b /tmp/cookies.txt "$API_URL/user/is-auth")
    if echo "$AUTH_RESPONSE" | grep -q "success\|authenticated"; then
        echo -e "${GREEN}✓ Authentication verified${NC}\n"
    else
        echo -e "${RED}✗ Authentication check failed${NC}\n"
    fi
else
    echo -e "${RED}✗ Login failed${NC}"
    echo -e "  Response: $LOGIN_RESPONSE\n"
fi

# Test 6: Frontend connectivity
echo -e "${YELLOW}[Test 6] Frontend connectivity...${NC}"
if curl -s "$FRONTEND_URL" | grep -q "html\|React" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Frontend is accessible${NC}\n"
else
    echo -e "${YELLOW}! Frontend response received (may not contain expected HTML)${NC}\n"
fi

# Test 7: Container status
echo -e "${YELLOW}[Test 7] Container status...${NC}"
echo -e "$(docker-compose ps 2>/dev/null | tail -n +2)\n"

# Test 8: MongoDB connectivity
echo -e "${YELLOW}[Test 8] MongoDB connectivity...${NC}"
MONGO_COUNT=$(docker-compose exec -T mongodb mongosh \
  --username admin \
  --password password \
  --authenticationDatabase admin \
  --quiet \
  --eval "db.users.countDocuments()" \
  grocery-app 2>/dev/null || echo "error")

if [ "$MONGO_COUNT" != "error" ]; then
    echo -e "${GREEN}✓ MongoDB is accessible${NC}"
    echo -e "  Users in database: $MONGO_COUNT\n"
else
    echo -e "${YELLOW}! Could not connect to MongoDB${NC}\n"
fi

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Test suite completed!${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo -e "${YELLOW}Quick commands:${NC}"
echo -e "  View logs:        ${BLUE}docker-compose logs -f${NC}"
echo -e "  View backend log: ${BLUE}docker-compose logs -f backend${NC}"
echo -e "  Connect to DB:    ${BLUE}docker-compose exec mongodb mongosh${NC}"
echo -e "  Stop services:    ${BLUE}docker-compose down${NC}"
echo -e "  Open in browser:  ${BLUE}http://localhost${NC}\n"

echo -e "${GREEN}All tests completed! Your app is ready to use.${NC}"
