pragma solidity ^0.8.19;

/**
 * @dev Interface of the Gateway Self External Calls.
 */
interface IDapp {
    function iReceive(string memory requestSender, bytes memory packet, string memory srcChainId) external returns (bytes memory);

    function iAck(uint256 requestIdentifier, bool execFlags, bytes memory execData) external;
}
