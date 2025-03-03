#!/bin/bash

# Load environment variables
source .env

# Verify environment variables are set
if [ -z "$PRIVATE_KEY" ] || [ -z "$ETHERSCAN_API_KEY" ]; then
    echo "Missing required environment variables"
    exit 1
fi


forge script script/Karu.s.sol \
--rpc-url https://base.publicnode.com \
--broadcast \
--verify \
--legacy \
--private-key ${PRIVATE_KEY} \
--etherscan-api-key ${ETHERSCAN_API_KEY} \
--gas-price 3000000000 \
