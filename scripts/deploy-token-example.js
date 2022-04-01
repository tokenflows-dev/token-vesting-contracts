async function main() {
    // We get the contract to deploy
    const ERC20Example = await ethers.getContractFactory("ERC20Example");
    const erc20 = await ERC20Example.deploy();

    console.log("ERC20 example token deployed to:", erc20.address);
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
