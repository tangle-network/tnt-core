// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

library TypeCasts {
    // alignment preserving cast
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    // alignment preserving cast
    function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
        require(uint256(_buf) <= uint256(type(uint160).max), "TypeCasts: bytes32ToAddress overflow");
        return address(uint160(uint256(_buf)));
    }
}
