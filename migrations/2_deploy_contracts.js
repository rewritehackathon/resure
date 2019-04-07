var User = artifacts.require("./User.sol");
var Car = artifacts.require("./Car.sol");


module.exports = function(deployer) {
  deployer.deploy(User);
  deployer.deploy(Car);
};
