// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract PermittedCaller {
    address public permitted;

    constructor() {
        permitted = msg.sender;
    }

    modifier onlyPermittedCaller() {
        require(msg.sender == permitted, "Only permitted caller can call this function");
        _;
    }
}

contract RootChainEnabled {
    /// @dev address(keccak256(pallet_services::Config::PalletId::to_account_id())[0:20])
    address public constant ROOT_CHAIN = 0x6d6f646c70792F73727663730000000000000000;

    function rootChainOrigin() public pure returns (address) {
        return ROOT_CHAIN;
    }

    /// @dev Only root chain can call this function
    /// @notice This function can only be called by the root chain
    modifier onlyFromRootChain() {
        require(msg.sender == ROOT_CHAIN, "RootChain: Only root chain can call this function");
        _;
    }
}

contract RootChainEnabledOwnable is Ownable, RootChainEnabled {
    constructor() Ownable() RootChainEnabled() { }

    modifier onlyOwnerOrRootChain() {
        require(msg.sender == owner() || msg.sender == rootChainOrigin(), "Unauthorized");
        _;
    }
}
