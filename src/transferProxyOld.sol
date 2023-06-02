// SPDX-License-Identifier: MiladyCometh
pragma solidity ^0.8.17;

/// @author lcfr.eth
/// @notice helper contract for Flashbots rescues using bundler.lcfr.io
/// @notice can also be used for airdropping ERC721 && ERC1155 effeciently
/// @dev :PpPPpPPppPPpPPpPPpP
import "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
contract transferProxy {

    error notApproved();
    error arrayLengthMismatch();

    /// @notice intended for doing transferFrom or safeTransferFrom from an approved address
    /// @dev !! unsafe !! DO - NOT - USE !! 
    /// attacker can set approval _from an address they control to an address they control on _contract
    /// then submit calldata for transferfrom/safetransferfrom with transfer calldata for a different previously/different approved address 

    function approvedCallUnsafe(bytes[] calldata _data, address _contract, address _from) external {
        assembly {
            // check if caller isApprovedForAll() by _from on _contract or revert
            mstore(0x00, shl(224, 0xe985e9c5))
            // store _from as the first parameter to isApprovedForAll()
            mstore(0x04, _from) 
            // store caller as the second parameter to isApprovedForAll()
            mstore(0x24, caller())
            // call _contract.isApprovedForAll(_from, caller())
            let success := staticcall(gas(), _contract, 0x00, 0x44, 0x00, 0x00)
            // copy return data to 0x00 
            returndatacopy(0x00, 0x00, returndatasize())
            // revert if the call was not successful
            if iszero(success) {
                revert(0x00, returndatasize())
            }
            // check if the return data is 0x01 (true) or revert
            if iszero(mload(0x00)) {
                mstore(0x00, 0x383462e2)
                revert(0x1c, 0x04)
            }
            // start our loop at 0
            let i := 0
            for {} 1 { i:= add(i, 1) } {
                // check if we have reached the end of the array. _data len starts at 1
                if eq(i, _data.length){ break }
                // elements of _data start at _data.offset
                let data := calldataload(add(_data.offset, shl(5, i)))
                // the length of the data is the first 32 bytes
                let len := calldataload(add(_data.offset, data))
                // the actual bytes start after the first 32 bytes 
                calldatacopy(0x00, add(_data.offset, add(data, 0x20)), len)
                // call the encoded method        
                success := call( gas(), _contract, 0x00, 0x00, len, 0x00, 0x00)

                if iszero(success) {
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0x00, returndatasize())
                }
            }
        }
    }

}