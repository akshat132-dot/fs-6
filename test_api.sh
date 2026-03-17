#!/bin/bash

# Configuration
API_URL="http://localhost:8080"
USERNAME="user123"
PASSWORD="password123"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}==============================================${NC}"
echo -e "${BLUE}       JWT Authentication Test Script       ${NC}"
echo -e "${BLUE}==============================================${NC}\n"

echo -e "${GREEN}[1] Testing Access without Authentication...${NC}"
echo -e "Sending GET request to /protected..."
curl -s -w "\nHTTP Status: %{http_code}\n" -X GET "$API_URL/protected"
echo -e "\n"

echo -e "${GREEN}[2] Performing Login Request...${NC}"
echo -e "Sending POST request to /login with credentials: $USERNAME / $PASSWORD"
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}")

echo -e "Login Response:"
echo -e "${BLUE}$LOGIN_RESPONSE${NC}\n"

# Extract token using grep/sed (simple JSON extraction without jq)
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | grep -o '[^"]*$')

if [ -z "$TOKEN" ]; then
    echo -e "${RED}Error: Failed to obtain JWT token.${NC}"
    exit 1
fi

echo -e "Extracted Token:"
echo -e "${BLUE}$TOKEN${NC}\n"

echo -e "${GREEN}[3] Testing Access WITH valid JWT Token...${NC}"
echo -e "Sending GET request to /protected with Authorization header..."
curl -s -w "\nHTTP Status: %{http_code}\n" -X GET "$API_URL/protected" \
  -H "Authorization: Bearer $TOKEN"
echo -e "\n"

echo -e "${GREEN}[4] Testing 'Logout' / Invalid Token...${NC}"
echo -e "Sending GET request to /protected with an invalid (modified) token..."
curl -s -w "\nHTTP Status: %{http_code}\n" -X GET "$API_URL/protected" \
  -H "Authorization: Bearer ${TOKEN}_invalidated"
echo -e "\n"

echo -e "${BLUE}==============================================${NC}"
echo -e "${BLUE}                   Done!                      ${NC}"
echo -e "${BLUE}==============================================${NC}"