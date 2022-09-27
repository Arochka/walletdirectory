<script setup lang="ts">
import { ref, onMounted } from "vue";
import { ethers } from "ethers";
import walletDirectoryAbi from "./contracts/WalletDirectory.json";
import WalletDirectoryCoinAbi from "./contracts/WalletDirectoryCoin.json";

interface WalletContact {
  Name: string;
  Email: string;
  PhoneNumber: string;
  StackedTokens: number;
}

const contractAddress = "0x0f87f3018a74Ea58eC5f67680de45E724AF2F03E";
const contractABI = walletDirectoryAbi.abi;

const coinAddress = "0x87a725B3dF717C3c0a36Ebc5f34Bfa3C618aF0fd";
const coinABI = WalletDirectoryCoinAbi.abi;

let currentAccount = ref("");
let search = ref("");
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
    const contact = await getWalletContact(currentAccount.value);
    if (contact) {
      currentContact.value = {
        Name: contact.Name,
        Email: contact.Email,
        PhoneNumber: contact.PhoneNumber,
        StackedTokens: contact.StackedTokens,
      };
    }
  } catch (error) {
    console.error(error);
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

async function approveTokens(amount: number) {
  try {
    const { ethereum } = window;
    if (!ethereum) {
      console.error("No metamask");
      return;
    }

    const provider = new ethers.providers.Web3Provider(ethereum);
    const signer = provider.getSigner();
    const coinContract = new ethers.Contract(coinAddress, coinABI, signer);

    const txn = await coinContract.approve(contractAddress, amount);
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

    if (allowance < amount) {
      await approveTokens(amount);
    }

    const txn = await walletDirectoryContract.acceptTransfer(amount);
    console.log("Accept transfer...");
    await txn.wait();
    console.log("Transfer accepted", txn.hash);
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
            <span class="font-semibold">Stacked Tokens: </span>
            <span class="font-thin">{{ currentContact.StackedTokens }}</span>
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
        <button
          class="inline-block bg-gray-900 hover:bg-gray-800 text-white font-medium rounded-lg py-2 mt-2 leading-tight w-full"
          @click="stackTokens(100)"
        >
          Stack 100 Tokens
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
