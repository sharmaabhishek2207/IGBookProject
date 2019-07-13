// Fetch the IGBookContract contract data from the IGBookContract.json file
var IGBookContract = artifacts.require("./IGBookContract.sol");

// JavaScript export
module.exports = function(deployer) {
    // Deployer is the Truffle wrapper for deploying
    // contracts to the network

    // Deploy the contract to the network
    deployer.deploy(IGBookContract);
}