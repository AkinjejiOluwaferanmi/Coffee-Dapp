# ☕ Buy Me a Coffee — FundMe Dapp

A simple, gas-efficient smart-wallet contract that lets anyone send ETH to the owner — with a clean TypeScript + [viem](https://viem.sh/) frontend to interact with it. Think "Buy Me a Coffee," but fully on-chain.

Built with [Foundry](https://book.getfoundry.sh/) for the contract side and [Vite](https://vitejs.dev/) for the frontend.

---

## ✨ Features

- **`fund()`** — anyone can deposit ETH (also triggered automatically via `receive()` / `fallback()`)
- **`withdraw()`** — owner-only, sweeps the full contract balance to the owner
- **`withdrawTo(address, amount)`** — owner-only, sends an arbitrary amount to an arbitrary address
- Per-funder contribution tracking (`getContribution`, `getFunder`, `getFundersCount`)
- Custom errors instead of `require` strings for cheaper reverts
- Frontend built with **viem** — wallet connection, contract simulation before sending, and balance checks
- Automatic revert-reason decoding in the UI (via `ContractFunctionRevertedError`)

---

## 🗂 Project Structure

## Project Structure

```text
.
├── contracts/
│   ├── .github/        # GitHub configuration
│   ├── broadcast/      # Deployment broadcasts
│   ├── lib/            # Contract libraries/dependencies
│   ├── script/         # Deployment and utility scripts
│   ├── src/           # Smart contract source files
|       ├──FundMe.sol
│   ├── test/           # Smart contract tests
│   ├── .gitignore
│   ├── .gitmodules
│   ├── foundry.lock
│   ├── foundry.toml
│   └── README.md
│
├── constants-ts.ts     # TypeScript constants
├── index-ts.ts         # TypeScript entry point
├── index.html          # Frontend entry point
├── package.json        # Project dependencies and scripts
├── pnpm-lock.yaml      # Dependency lock file
├── styles.css          # Application styles
├── tsconfig.json       # TypeScript configuration
└── README.md           # Project documentation


---

## 🔧 Tech Stack

| Layer      | Tool                                   |
|------------|-----------------------------------------|
| Smart contract | Solidity `^0.8.20`                  |
| Dev framework  | [Foundry](https://book.getfoundry.sh/) (Forge, Cast, Anvil) |
| Frontend       | TypeScript + [Vite](https://vitejs.dev/) |
| Web3 library   | [viem](https://viem.sh/)             |
| Wallet         | MetaMask (or any injected `window.ethereum` provider) |

---

## 📋 Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed (`forge`, `cast`, `anvil`)
- [Node.js](https://nodejs.org/) (v18+) and npm/yarn/pnpm
- [MetaMask](https://metamask.io/) browser extension

---

## 🚀 Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```

### 2. Install contract dependencies

```bash
forge install
```

### 3. Build the contracts

```bash
forge build
```

### 4. Run the tests

```bash
forge test
```

Add `-vvv` for verbose traces if a test fails:

```bash
forge test -vvv
```

### 5. Start a local chain (Anvil)

In one terminal:

```bash
anvil
```

This spins up a local Ethereum node at `http://127.0.0.1:8545` and gives you 10 funded test accounts.

### 6. Deploy the contract locally

In a second terminal:

```bash
forge script script/DeployFundMe.s.sol --rpc-url http://127.0.0.1:8545 --private-key <ANVIL_PRIVATE_KEY> --broadcast
```

Copy the deployed contract address printed in the output — you'll need it for the frontend.

### 7. Configure the frontend

Open `frontend/constants-ts.ts` and update:

```ts
export const contractAddress = "0xYourDeployedContractAddress";
export const abi = [ /* ... your ABI ... */ ];
```

### 8. Install frontend dependencies

```bash
cd frontend
npm install
```

### 9. Run the frontend

```bash
npm run dev
```

Vite will print a local URL (usually `http://localhost:5173`). Open it in a browser with MetaMask installed.

### 10. Connect MetaMask to your local chain

If testing against Anvil, add a custom network in MetaMask:

| Field | Value |
|---|---|
| Network Name | Anvil |
| RPC URL | `http://127.0.0.1:8545` |
| Chain ID | `31337` |
| Currency Symbol | ETH |

Then import one of the private keys Anvil printed on startup so you have test ETH to play with.

---

## 🖥 Using the App

1. **Connect Wallet** — connects MetaMask and displays your connected address
2. **Get Balance** — logs the contract's current ETH balance to the console
3. **ETH Amount** — enter the amount of ETH to send (e.g. `0.01`)
4. **Buy Coffee** — simulates the `fund()` call, then submits the transaction
5. **Withdraw** — owner-only; simulates and submits the `withdraw()` call, sweeping the balance to the owner

Any contract revert (e.g. `FundMe__NeedsMoreThanZero`, `FundMe__NotOwner`) is caught and shown to the user via an alert.

---

## 🌐 Deploying to a Testnet

1. Set up a `.env` file (never commit this):

```env
SEPOLIA_RPC_URL=https://your-rpc-url
PRIVATE_KEY=your-private-key
ETHERSCAN_API_KEY=your-etherscan-key
```

2. Deploy:

```bash
forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

3. Update `contractAddress` in `frontend/constants-ts.ts` with the deployed address.

4. Build and deploy the frontend (e.g. to Vercel or Netlify):

```bash
npm run build
```

---

## 🔐 Security Notes

- `withdraw()` and `withdrawTo()` are restricted to `i_owner` via the `onlyOwner` modifier
- Contract uses the checks-effects-interactions pattern: state (`s_contributions`, `s_funders`) is cleared **before** the external call in `withdraw()`
- Uses low-level `.call{value: amount}("")` with a success check rather than `transfer`/`send`, avoiding fixed gas-stipend issues
- Custom errors keep revert costs low

This contract has not been professionally audited — treat it as a learning project, not production-ready financial infrastructure.

---

## 📝 License

MIT

---

## 🙋 Author

**Akinjeji Oluwaferanmi**

This was my first full dapp — smart contract, tests, deployment scripts, and a working TypeScript frontend wired up end-to-end with viem. 🎉