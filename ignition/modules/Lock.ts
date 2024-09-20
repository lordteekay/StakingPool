// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { deployContract } from "@nomicfoundation/hardhat-ethers/types";
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Sign } from "crypto";

// const LockModule = buildModule("LockModule", (m) => {

//   const lock = m.contract("MyNFT", [],{
//     signature:SignerWithAddress
//   });

//   return { lock };
// });

// export default LockModule;
console.log(Sign);
