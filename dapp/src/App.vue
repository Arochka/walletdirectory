<script setup lang="ts">
import { ref, onMounted } from "vue";
import { ethers, BigNumber } from "ethers";
import walletDirectoryAbi from "./contracts/WalletDirectory.json";
import WalletDirectoryCoinAbi from "./contracts/WalletDirectoryCoin.json";
import NFTAbi from "./contracts/GtrpNFT.json";

interface WalletContact {
  Name: string;
  Email: string;
  PhoneNumber: string;
  StackedTokens: number;
}

const contractAddress = "0x137c48AC10006cf2945556ACd9E3A36774784641";
const contractABI = walletDirectoryAbi.abi;

const coinAddress = "0x87a725B3dF717C3c0a36Ebc5f34Bfa3C618aF0fd";
const coinABI = WalletDirectoryCoinAbi.abi;

const nftAddress = "0x15c6a03df86E068d01DF7c1003d74D75687aB99c";
const nftABI = NFTAbi.abi;

const DECIMAL = BigNumber.from(10).pow(18);

let currentAccount = ref("");
let search = ref("");
let stackAmount = ref(0);
let mintPrice = ref(0);
let currentContact = ref();
let searchContact = ref();

onMounted(() => {
  checkIfWalletIsConnected();
});

async function checkIfWalletIsConnected() {
  try {
    const { ethereum } = window;

    if (!ethereum) {
      console.error("No metamask");
      return;
    }

    const accounts = await ethereum.request({ method: "eth_requestAccounts" });

    if (accounts.length === 0) {
      console.error("No Accounts");
      return;
    }

    currentAccount.value = accounts[0];

    console.log("Current account: ", currentAccount);
    await refreshWalletContact();

    mintPrice.value = await getMintPrice();
  } catch (error) {
    console.error(error);
  }
}

async function refreshWalletContact() {
  const contact = await getWalletContact(currentAccount.value);
  if (contact) {
    currentContact.value = {
      Name: contact.Name,
      Email: contact.Email,
      PhoneNumber: contact.PhoneNumber,
      StackedTokens: contact.StackedTokens,
    };
  }
}

async function searchWalletContact() {
  const contact = await getWalletContact(search.value);
  searchContact.value = contact;
}

async function getWalletContact(
  walletAddress: string
): Promise<WalletContact | null> {
  try {
    const { ethereum } = window;
    if (!ethereum) {
      console.error("No metamask");
      return null;
    }

    const provider = new ethers.providers.Web3Provider(ethereum);
    const signer = provider.getSigner();
    const walletDirectoryContract = new ethers.Contract(
      contractAddress,
      contractABI,
      signer
    );

    const walletContact: WalletContact =
      await walletDirectoryContract.getWalletContact(walletAddress);

    console.log("getWalletContact: ", walletContact);
    return walletContact;
  } catch (error) {
    console.error(error);
    return null;
  }
}

async function setWalletContact() {
  try {
    const { ethereum } = window;
    if (!ethereum) {
      console.error("No metamask");
      return;
    }

    const provider = new ethers.providers.Web3Provider(ethereum);
    const signer = provider.getSigner();
    const walletDirectoryContract = new ethers.Contract(
      contractAddress,
      contractABI,
      signer
    );

    const txn = await walletDirectoryContract.setContact(currentContact.value);
    console.log("Set contact...");
    await txn.wait();
    console.log("Contact Set", txn.hash);
  } catch (error) {
    console.error(error);
  }
}

async function approveTokens(address: string, amount: BigNumber) {
  try {
    const { ethereum } = window;
    if (!ethereum) {
      console.error("No metamask");
      return;
    }

    const provider = new ethers.providers.Web3Provider(ethereum);
    const signer = provider.getSigner();
    const coinContract = new ethers.Contract(coinAddress, coinABI, signer);

    const txn = await coinContract.approve(address, amount);
    console.log("Approve tokens...");
    await txn.wait();
    console.log("Tokens approval", txn.hash);
  } catch (error) {
    console.error(error);
  }
}

async function stackTokens(amount: number) {
  try {
    const { ethereum } = window;
    if (!ethereum) {
      console.error("No metamask");
      return;
    }

    const provider = new ethers.providers.Web3Provider(ethereum);
    const signer = provider.getSigner();
    const walletDirectoryContract = new ethers.Contract(
      contractAddress,
      contractABI,
      signer
    );

    const allowance = await walletDirectoryContract.getAllowance();
    console.log("Allowance: ", allowance);

    const convertAmount = BigNumber.from(amount).mul(DECIMAL);

    if (allowance < convertAmount) {
      await approveTokens(contractAddress, convertAmount);
    }

    const txn = await walletDirectoryContract.acceptTransfer(convertAmount);
    console.log("Accept transfer...");
    await txn.wait();
    console.log("Transfer accepted", txn.hash);
    await refreshWalletContact();
  } catch (error) {
    console.error(error);
  }
}

async function mintNFT() {
  try {
    const { ethereum } = window;
    if (!ethereum) {
      console.error("No metamask");
      return;
    }

    const provider = new ethers.providers.Web3Provider(ethereum);
    const signer = provider.getSigner();
    const nftContract = new ethers.Contract(nftAddress, nftABI, signer);

    const allowance = await nftContract.getAllowance();
    console.log("Allowance: ", allowance);

    const convertAmount = BigNumber.from(mintPrice.value).mul(DECIMAL);

    if (allowance < convertAmount) {
      console.log("Approving...");
      await approveTokens(nftAddress, convertAmount);
      console.log("Approved");
    }

    const txn = await nftContract.safeMint(currentAccount.value);
    console.log("Minting...");
    await txn.wait();
    console.log("Minted", txn.hash);
  } catch (error) {
    console.error(error);
  }
}

async function getMintPrice() {
  try {
    const { ethereum } = window;
    if (!ethereum) {
      console.error("No metamask");
      return;
    }

    const provider = new ethers.providers.Web3Provider(ethereum);
    const signer = provider.getSigner();
    const nftContract = new ethers.Contract(nftAddress, nftABI, signer);

    return await nftContract.MINT_PRICE();
  } catch (error) {
    console.error(error);
  }
}
</script>

<template>
  <main class="bg-white antialiased">
    <div class="max-w-xl mx-auto px-8 mt-6">
      <nav>
        <div class="py-4 flex-shrink-0 flex items-center">
          <span class="ml-8 font-medium text-gray-900">Wallet Directory</span>
        </div>
        <div class="mt-2">
          <input
            type="text"
            class="block w-full border border-gray-300 rounded-lg bg-gray-100 px-3 py-2 leading-tight focus:outline-none focus:border-gray-600 focus:bg-white"
            placeholder="Search wallet address.."
            v-model="search"
          />
          <button
            class="inline-block bg-gray-900 hover:bg-gray-800 text-white font-medium rounded-lg py-2 mt-2 leading-tight w-full"
            @click="searchWalletContact"
          >
            Search
          </button>
        </div>
      </nav>
    </div>
    <div class="mt-6 sm:mt-0 sm:py-12" v-if="currentContact">
      <div class="mt-8 max-w-xl mx-auto px-8">
        <h1 class="text-center">
          <span class="block text-xl text-gray-600 leading-tight"
            >Your Wallet informations:</span
          >
        </h1>
        <div class="bg-gray-100 rounded-lg">
          <div>
            <span class="font-semibold">Wallet: </span>
            <span class="font-thin">{{ currentAccount }}</span>
          </div>
          <hr />
          <div>
            <span class="font-semibold">Email: </span>
            <input
              type="text"
              class="font-thin bg-gray-100"
              placeholder="Your email address.."
              v-model="currentContact.Email"
            />
          </div>
          <hr />
          <div>
            <span class="font-semibold">Name: </span>
            <input
              type="text"
              class="font-thin bg-gray-100"
              placeholder="Your name.."
              v-model="currentContact.Name"
            />
          </div>
          <hr />
          <div>
            <span class="font-semibold">PhoneNumber: </span>
            <input
              type="text"
              class="font-thin bg-gray-100"
              placeholder="Your phone number.."
              v-model="currentContact.PhoneNumber"
            />
          </div>
        </div>
        <button
          class="inline-block bg-gray-900 hover:bg-gray-800 text-white font-medium rounded-lg py-2 mt-2 leading-tight w-full"
          @click="setWalletContact"
        >
          Set Contact informations
        </button>
      </div>
    </div>
    <div class="mt-6 sm:mt-0 sm:py-12" v-if="currentContact">
      <div class="mt-8 max-w-xl mx-auto px-8">
        <h1 class="text-center">
          <span class="block text-xl text-gray-600 leading-tight"
            >Stack/Mint:</span
          >
        </h1>
        <div class="bg-gray-100 rounded-lg">
          <div>
            <span class="font-semibold">Stacked Tokens: </span>
            <span class="font-thin">{{ currentContact.StackedTokens }}</span>
          </div>
          <div>
            <span class="font-semibold">Mint Price: </span>
            <span class="font-thin">{{ mintPrice }}</span>
          </div>
          <hr />
          <div>
            <span class="font-semibold">Stack Amount: </span>
            <input
              type="number"
              class="font-thin bg-gray-100"
              placeholder="Amount.."
              v-model="stackAmount"
            />
          </div>
        </div>
        <button
          class="inline-block bg-gray-900 hover:bg-gray-800 text-white font-medium rounded-lg py-2 mt-2 leading-tight w-full"
          @click="stackTokens(stackAmount)"
        >
          Stack {{ stackAmount }} Tokens
        </button>
        <button
          class="inline-block bg-gray-900 hover:bg-gray-800 text-white font-medium rounded-lg py-2 mt-2 leading-tight w-full"
          @click="mintNFT()"
        >
          Mint NFT
        </button>
      </div>
    </div>
    <div class="mt-6 sm:mt-0 sm:py-12" v-if="searchContact">
      <div class="mt-8 max-w-xl mx-auto px-8">
        <h1 class="text-center">
          <span class="block text-xl text-gray-600 leading-tight"
            >Search result:</span
          >
        </h1>
        <div class="bg-gray-100 rounded-lg">
          <div>
            <span class="font-semibold">Email: </span>
            <span class="font-thin">{{ searchContact.Email }}</span>
          </div>
          <hr />
          <div>
            <span class="font-semibold">Name: </span>
            <span class="font-thin">{{ searchContact.Name }}</span>
          </div>
          <hr />
          <div>
            <span class="font-semibold">PhoneNumber: </span>
            <span class="font-thin">{{ searchContact.PhoneNumber }}</span>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<style scoped></style>
