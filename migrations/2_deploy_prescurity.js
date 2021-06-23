const Prescurity = artifacts.require("Prescurity");

module.exports = (deployer) => {
    deployer.deploy(Prescurity);
};