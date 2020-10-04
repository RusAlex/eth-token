// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT

/* Mint 200,000,000 tokens (fixed supply)
 120,000,000 tokens for sale (60%)
 rest 28% issued to predefined addresses
 last 12% reserved for token bonus.
 20% token bonus on all purchases during crowdsale (so 144,000,000 tokens issued in sale).
 Crowdsale closes once 120,000,000 tokens are sold, no time limit. or when owner closed it
 Owner can end crowdsale at any time. q: where non sold tokens go ?
 Owner can change token price at any time.
 Token transfers locked during crowdsale. */

pragma solidity 0.6.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Token is ERC20Capped, Ownable {
    using SafeMath for uint256;

    // how many token units a buyer gets per wei
    uint256 public rate;

    address payable constant public BUDGET0_ADDRESS = 0xb8E64A990f0f235442aa81e13fF314DE1dFbE1f9;

    bool crowdSaleFinished = false;

    constructor() public ERC20("Trilli", "TRL") ERC20Capped(200000000 * (10 ** 18)) {
        _mint(msg.sender, SafeMath.mul(56000000,(10**18)));
        // init predefined address distribution
    }

    function finishCrowdSale() public onlyOwner  {
        crowdSaleFinished = true;
    }

    function isCrowdsaleFinished() public view returns (bool)  {
        return crowdSaleFinished;
    }

    function updateRate(uint256 _newRate) public onlyOwner {
        rate = percent(_newRate).div(10); // TRL:ETH , 1 / (ethprice * 10). price of eth in cents
    }

    // low level token purchase function
    receive() external payable {
        require(msg.sender != address(0));

        uint256 weiAmount = msg.value;
        // calculate token amount to be created
        uint256 tokens = getTokenAmount(weiAmount);

        _mint(msg.sender, tokens);
        BUDGET0_ADDRESS.transfer(msg.value);
    }

    // Override this method to have a way to add business logic to your crowdsale when buying
    function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
        uint256 amount = SafeMath.div(SafeMath.mul(weiAmount, rate), percent(1)); // TRL:ETH
        return amount; // TRL:ETH
    }

    /**
     * Requirements:
     *
     * crowdsale should be closed now
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from != address(0)) { // When transferring tokens not minting
            require(crowdSaleFinished, "Token: crowdsale finished");
        }
    }

    // used to get more precise division
    function percent(uint256 p) internal pure returns (uint256) {
        return SafeMath.mul(p, 10**16);
    }
}
