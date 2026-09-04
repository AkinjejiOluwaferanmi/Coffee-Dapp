import {
  createWalletClient,
  custom,
  createPublicClient,
  parseEther,
  defineChain,
  formatEther,
  BaseError,
  ContractFunctionRevertedError,
  type WalletClient,
  type PublicClient,
  type Chain,
} from "viem";
import { contractAddress, abi } from "./constants-ts";
import "viem/window";

// --- DOM elements ------------------------------------------------------------
const connectButton = document.getElementById("connectButton") as HTMLButtonElement;
const fundButton = document.getElementById("fundButton") as HTMLButtonElement;
const ethAmountInput = document.getElementById("ethAmount") as HTMLInputElement;
const balanceButton = document.getElementById("balanceButton") as HTMLButtonElement;
const withdrawButton = document.getElementById("withdrawButton") as HTMLButtonElement;

let walletClient: WalletClient;
let publicClient: PublicClient;

async function connect(): Promise<void> {
  if (typeof window.ethereum !== "undefined") {
    console.log("Connecting...");

    walletClient = createWalletClient({
      transport: custom(window.ethereum),
    });

    try {
      // Wait for the user to connect their wallet
      const addresses = await walletClient.requestAddresses();
      console.log("Connected accounts:", addresses); // Log the connected address(es)

      // This code now runs ONLY AFTER the await completes successfully
      connectButton.innerHTML = `Connected: ${addresses[0].slice(0, 6)}...`; // Show part of address
      console.log("Connection successful!");
    } catch (error) {
      // Handle errors, like the user rejecting the connection
      console.error("Connection failed:", error);
      connectButton.innerHTML = "Connection Failed"; // Reset button text on failure
    }
  } else {
    connectButton.innerHTML = "Please install MetaMask!";
  }
}

async function fund(): Promise<void> {
  const ethAmount = ethAmountInput.value;
  console.log(`Funding with ${ethAmount}...`);

  if (typeof window.ethereum !== "undefined") {
    try {
      walletClient = createWalletClient({
        transport: custom(window.ethereum),
      });
      const [account] = await walletClient.requestAddresses();
      const currentChain = await getCurrentChain(walletClient);

      console.log("Processing transaction...");
      console.log("Current Chain: ", currentChain.name);
      publicClient = createPublicClient({
        transport: custom(window.ethereum),
      });
      const { request } = await publicClient.simulateContract({
        address: contractAddress,
        abi,
        functionName: "fund",
        account,
        chain: currentChain,
        value: parseEther(ethAmount),
      });

      const hash = await walletClient.writeContract(request);

      console.log("Transaction processed: ", hash);
    } catch (error) {
      if (error instanceof BaseError) {
        const revertError = error.walk(
          (error) => error instanceof ContractFunctionRevertedError,
        );
        if (revertError instanceof ContractFunctionRevertedError) {
          const errorName = revertError.data?.errorName ?? "";
          console.log("Error: ", errorName);
          alert(errorName);
        }
      } else {
        console.log("Error: ", error);
      }
    }
  } else {
    fundButton.innerHTML = "Please install MetaMask";
  }
}

async function withdraw(): Promise<void> {
  if (typeof window.ethereum !== "undefined") {
    try {
      walletClient = createWalletClient({ transport: custom(window.ethereum) });

      const [connectedAccount] = await walletClient.requestAddresses();
      console.log("Withdrawing Funds To: ", connectedAccount);

      const currentChain = await getCurrentChain(walletClient);

      console.log("Processing Transaction....");
      console.log("Current chain: ", currentChain.name);

      publicClient = createPublicClient({ transport: custom(window.ethereum) });

      const { request } = await publicClient.simulateContract({
        address: contractAddress,
        abi,
        functionName: "withdraw",
        account: connectedAccount,
        chain: currentChain,
      });

      const hash = await walletClient.writeContract(request);
      console.log("Transaction Processed: ", hash);
    } catch (error) {
      if (error instanceof BaseError) {
        const revertError = error.walk(
          (error) => error instanceof ContractFunctionRevertedError,
        );
        if (revertError instanceof ContractFunctionRevertedError) {
          const errorName = revertError.data?.errorName ?? "";
          console.log("Error: ", errorName);
          alert(errorName);
        }
      } else {
        console.log("Error: ", error);
      }
    }
  }
}

async function getBalance(): Promise<void> {
  if (typeof window.ethereum !== "undefined") {
    console.log("Connecting...");

    publicClient = createPublicClient({
      transport: custom(window.ethereum),
    });

    const balance = await publicClient.getBalance({
      address: contractAddress,
    });

    console.log(formatEther(balance));
  } else {
    connectButton.innerHTML = "Please install MetaMask!";
  }
}

async function getCurrentChain(client: WalletClient): Promise<Chain> {
  // Get the chain ID from the connected wallet client
  const chainId = await client.getChainId();

  // Define the chain parameters using viem's defineChain
  const currentChain = defineChain({
    id: chainId,
    name: "Anvil", // Provide a descriptive name (e.g., Anvil, Hardhat)
    nativeCurrency: {
      name: "Ether",
      symbol: "ETH",
      decimals: 18,
    },
    rpcUrls: {
      // Use the RPC URL of your local node
      default: { http: ["http://localhost:8545"] },
      // public: { http: ["http://localhost:8545"] }, // Optional: specify public RPC if different
    },
    // Add other chain-specific details if needed (e.g., blockExplorers)
  });
  return currentChain;
}

connectButton.onclick = connect;
fundButton.onclick = fund;
balanceButton.onclick = getBalance;
withdrawButton.onclick = withdraw;