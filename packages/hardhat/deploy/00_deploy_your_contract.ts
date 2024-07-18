import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";
import { ethers } from "hardhat";


const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {

  // const { deployer } = await hre.getNamedAccounts();
  const [ deployer ] = await ethers.getSigners();
 
  const { deploy } = hre.deployments;

  await deploy("Counter", {
    from: deployer.address,
    args: ["0x7702eD777B5d6259483baAD0FE8b9083eF937E2A"],
    log: true,
    autoMine: true,
  });

  // Get the deployed contract to interact with it after deploying.
  const gateway = await hre.ethers.getContract<Contract>("Counter", deployer);
  const gatewayAddress = await gateway.getAddress();
  console.log("deploying contracts with the account ", deployer.address);
  console.log(gatewayAddress);


  // const makeCall = await gateway.makeCall(ethers.zeroPadValue("0x5b240A6F86a180C795ab1328F2F3567d113DEF26", 32), 7, {value: ethers.parseEther("0.01")});
  // await makeCall.wait();
  // console.log("MakeCall Hash: ", makeCall.hash);

  // const sendMessage = await gateway.sendMessage("0x000000007f56768de3133034fa730a909003a165", 7, 100000, ethers.getBytes("0x1234567890abcdef"));
  // await sendMessage.wait();
  // console.log("SendMessage Hash: ", sendMessage.hash);

 
};

export default deployYourContract;

deployYourContract.tags = ["Counter"];
