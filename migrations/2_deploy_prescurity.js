const Prescurity = artifacts.require("Prescurity");

module.exports = (deployer) => {
    if(!process.env.OWNER_ADDRESS){
        const m = "Please set up an 'OWNER_ADDRESS' environnemental variable inside the .env";
        console.error(m);
        throw new Error(m)
    }
    deployer.deploy(Prescurity, {from: process.env.OWNER_ADDRESS});
};