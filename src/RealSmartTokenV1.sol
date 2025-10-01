//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract RealSmartTokenV1 is OwnableUpgradeable, UUPSUpgradeable, ERC20PausableUpgradeable {
/// @custom:oz-upgrades-unsafe-allow constructor
    constructor() { _disableInitializers(); }


    function initialize(string memory _name, string memory _symbol, address _owner, uint256 _initialSupply) initializer public {
        __Ownable_init(_owner);
        __UUPSUpgradeable_init();
        __ERC20_init(_name, _symbol);   
        __Pausable_init();
        _mint(_owner, _initialSupply);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
    function pause() external onlyOwner {
        _pause();
    }
    function unpause() external onlyOwner {
        _unpause();
    }


    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}

}