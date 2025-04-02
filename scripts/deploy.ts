import { ethers } from "hardhat";

async function main() {
    const [deployer, user] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);
    //console.log("User:", user.address);
	
	 // 設置黑名單
	const specifiedAddress = "0xcd6d3aAd72F811C5E895582A2124594c157FF53e";

    console.log("Blacklisting user...");
    const blacklistTx = await faucet.setBlacklist(specifiedAddress, true);
    await blacklistTx.wait();
    console.log("User blacklisted");
	
    // 部署 Faucet 合約
    const Faucet = await ethers.getContractFactory("Faucet");
    const faucet = await Faucet.deploy({ value: ethers.parseEther("0.0001") });
    await faucet.waitForDeployment();
    console.log("Faucet deployed at:", await faucet.getAddress());

    // 確保 user 有足夠的 ETH
    //const userBalance = await ethers.provider.getBalance(user.address);
    //console.log("User Balance:", ethers.formatEther(userBalance), "ETH");
    /*if (userBalance < ethers.parseEther("0.01")) {
        console.error("Error: User does not have enough ETH to send transactions.");
        return;
    }*/

    // 讓 user 提款
    console.log("User attempting to withdraw...");
    const faucetWithUser = faucet.connect(deployer);
    const withdrawTx = await faucetWithUser.withdraw();
    await withdrawTx.wait();
    console.log("Withdraw successful");

   
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
