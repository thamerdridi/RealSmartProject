//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@openzeppelin-foundry-upgrades/Upgrades.sol";
import "../src/RealSmartTokenV1.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        string memory name   = vm.envString("NAME");
        string memory symbol = vm.envString("SYMBOL");
        address owner        = vm.envAddress("OWNER");
        uint256 initialSupply = vm.envUint("INITIAL_SUPPLY");
        
        vm.startBroadcast(deployerPrivateKey);
        address proxy = Upgrades.deployUUPSProxy(
        "RealSmartTokenV1.sol", 
        abi.encodeCall(RealSmartTokenV1.initialize, (name, symbol, owner, initialSupply))
);      
        console.log("Proxy deployed to:", proxy);
        vm.stopBroadcast();
    }

}