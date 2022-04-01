require('dotenv').config()

async function main() {

    const STARTING_TIME = 1631731978 + 300; // starting time in unix timestamp
    const DURATION = 7776000;

    // We get the contract to deploy
    const Vesting = await ethers.getContractFactory("VestingPeriod");
    const vesting = await Vesting.deploy(process.env.RINKEBY_ERC20, STARTING_TIME, DURATION);

    console.log("Vesting Period deployed to:", vesting.address);
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
