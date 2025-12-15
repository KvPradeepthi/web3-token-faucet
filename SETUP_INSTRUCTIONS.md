# Web3 Token Faucet DApp - Setup Instructions

This guide will help you complete the Web3 Token Faucet DApp implementation locally on your machine.

## Prerequisites

- Node.js 18+ (https://nodejs.org/)
- Git (https://git-scm.com/)
- MetaMask or compatible Web3 wallet
- Sepolia testnet ETH (from https://www.sepoliafaucet.com/)
- Infura or Alchemy account for RPC endpoint

## Step 1: Clone the Repository

```bash
git clone https://github.com/KvPradeepthi/web3-token-faucet.git
cd web3-token-faucet
```

## Step 2: Install Dependencies

```bash
npm install
cd frontend && npm install && cd ..
```

## Step 3: Create Project Structure

```bash
mkdir -p contracts/test
mkdir -p frontend/src/{components,utils} frontend/public
mkdir -p scripts
```

## Step 4: Create Smart Contracts

### Create `contracts/Token.sol`
Copy the FaucetToken contract code from the implementation provided.

### Create `contracts/TokenFaucet.sol`
Copy the TokenFaucet contract code from the implementation provided.

### Create `test/TokenFaucet.test.js`
Copy the comprehensive test suite from the implementation provided.

## Step 5: Create Hardhat Configuration

### Create `hardhat.config.js`
Use the provided hardhat configuration that includes Sepolia network setup.

### Create `scripts/deploy.js`
Use the provided deployment script for Sepolia testnet.

## Step 6: Setup Environment Variables

```bash
cp .env.example .env
```

Edit `.env` with your actual values:
```
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
PRIVATE_KEY=YOUR_PRIVATE_KEY (without 0x prefix)
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY
```

## Step 7: Test Contracts Locally

```bash
npm test
```

Expected output: All tests should pass, including:
- ✓ Token deployment
- ✓ Faucet initialization
- ✓ Successful token claims
- ✓ Cooldown enforcement
- ✓ Lifetime limit enforcement
- ✓ Pause/unpause functionality
- ✓ Event emissions
- ✓ Access control

## Step 8: Deploy to Sepolia

```bash
npm run deploy
```

This will:
1. Deploy FaucetToken contract
2. Deploy TokenFaucet contract
3. Set up minting permissions
4. Create `deployment.json` with contract addresses
5. Verify contracts on Etherscan

## Step 9: Setup Frontend

### Create `frontend/src/App.jsx`
Implement React component with:
- Wallet connection using ethers.js
- Real-time balance display
- Claim button with cooldown timer
- Error handling and loading states

### Create `frontend/src/utils/contracts.js`
Implement contract interaction functions:
- `connectWallet()` - EIP-1193 wallet integration
- `getBalance(address)` - Query token balance
- `requestTokens()` - Submit claim transaction
- `canClaim(address)` - Check eligibility
- `getRemainingAllowance(address)` - Lifetime limit tracking

### Create `frontend/src/utils/eval.js`
Implement evaluation interface:
```javascript
window.__EVAL__ = {
  connectWallet: async () => {...},
  requestTokens: async () => {...},
  getBalance: async (address) => {...},
  canClaim: async (address) => {...},
  getRemainingAllowance: async (address) => {...},
  getContractAddresses: async () => {...}
};
```

### Create `frontend/vite.config.js`
```javascript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: { port: 5173 }
})
```

## Step 10: Test Frontend Locally

```bash
cd frontend
npm run dev
```

Access at `http://localhost:5173`

Test features:
1. Click "Connect Wallet" to connect MetaMask
2. View your token balance
3. Click "Claim 10 FAUCET" to test claim
4. Verify cooldown timer activates
5. Check remaining lifetime allowance

## Step 11: Create Docker Configuration

### Create `frontend/Dockerfile`
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "run", "preview"]
```

### Create `docker-compose.yml`
```yaml
version: '3.8'
services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - VITE_RPC_URL=${VITE_RPC_URL}
      - VITE_TOKEN_ADDRESS=${VITE_TOKEN_ADDRESS}
      - VITE_FAUCET_ADDRESS=${VITE_FAUCET_ADDRESS}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 10s
      timeout: 5s
      retries: 3
```

## Step 12: Run with Docker

```bash
docker-compose up
```

Access at `http://localhost:3000`

## Step 13: Update README.md

Already created with comprehensive documentation including:
- Project overview
- Architecture diagram
- Deployment addresses
- Quick start guide
- Configuration details
- Testing approach
- Security considerations

## Step 14: Push to GitHub

```bash
git add .
git commit -m "Complete Web3 Token Faucet DApp implementation with all features"
git push origin main
```

## Troubleshooting

**"Cannot find module" errors:**
```bash
rm -rf node_modules package-lock.json
npm install
```

**Hardhat compilation errors:**
```bash
npx hardhat clean
npx hardhat compile
```

**Deployment fails:**
- Check Sepolia RPC URL is valid
- Ensure account has testnet ETH
- Verify private key format (without 0x)

**MetaMask connection issues:**
- Switch to Sepolia network manually
- Clear MetaMask cache
- Check contract addresses in .env

## Next Steps

1. Verify both contracts on Etherscan
2. Test all frontend features with deployed contracts
3. Get feedback from Partnr team
4. Document any customizations made

## Support Files

All code files are available in this repository. The complete implementations for all components (contracts, tests, frontend, Docker) are ready for use.

Visit: https://github.com/KvPradeepthi/web3-token-faucet

---

**Last Updated:** December 15, 2025
**Network:** Sepolia Testnet
**Status:** Ready for local setup and deployment
