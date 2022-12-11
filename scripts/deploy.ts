import { utils } from "ethers";
import { ethers, run } from "hardhat";

const main = async () => {
  // Compile contracts
  // await run("compile");
  // console.log("Compiled contracts.");
  const PavoID = await ethers.getContractFactory("PavoID");
  // const pavoId = await PavoID.deploy();
  // await pavoId.deployed();
  const pavoId = await PavoID.attach("0x49C28dbdF6B50307e406Ab10B46bC25fa9626029");

  console.log("pavoId deploy to ", pavoId.address);
  const [deployer] = await ethers.getSigners();

  // await (await pavoId.mintByOwner(deployer.address, "hello")).wait();
  // console.log("minted");
  // console.log(await pavoId.tokenIdToDid(1));
  // console.log(await pavoId.tokenURI(1));
  await pavoId.updateOpen(true);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
