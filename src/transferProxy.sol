// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/// @author lcfr.eth
/// @notice helper contract for Flashbots rescues using bundler.lcfr.io
/// @notice can also be used for airdropping ERC721 && ERC1155 effeciently
/// @dev :PpPPpPPppPPpPPpPPpP

contract transferProxy {

    error notApproved();
    error arrayLengthMismatch();

    /// @notice intended for doing transferFrom or safeTransferFrom from an approved address
    /// @param _data array of encoded function calls
    /// @param _contract address of the contract to call
    /// @param _from address of the token owner to call on behalf of
    /// @dev checks if the caller isApprovedForAll() by _from on _contract or reverts
    /// @dev can work for transferring ERC721 or ERC1155 tokens
    function approvedCall(bytes[] calldata _data, address _contract, address _from) external {
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
                mstore(0x00, shl(224, 0x383462e2))
                revert(0x00, 0x04)
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

    /// @notice intended for transferring an array of tokens to an array of addresses from the owner
    function ownerDrop(uint256[] calldata tokenIds, address[] calldata _addrs, address _contract) external {

        assembly {
            // check if the arrays are the same length
            if iszero(eq(tokenIds.length, _addrs.length)) {
                mstore(0x00, shl(224, 0x543bf3c4))
                revert(0x00, 0x04)
            }

            // transferFrom(address,address,uint256) selector
            let transferFrom := 0x23b872ddac1db17cac1db17cac1db17cac1db17cac1db17cac1db17cac1db17c
            // store the selector at 0x00
            mstore(0x00, transferFrom)
            // store the caller as the first parameter to transferFrom()
            mstore(0x04, caller())

             let i := 0
             for {} 1 { i:= add(i, 1) } {
                if eq(i, tokenIds.length){ break }

                // offset for both arrays
                let offset := shl(5, i)

                // copy the address to send to as the second parameter to transferFrom()
                calldatacopy(0x24, add(_addrs.offset, offset), 0x20)

                // copy the token id as the third parameter to transferFrom()
                calldatacopy(0x44, add(tokenIds.offset, offset), 0x20)
                
                // call transferFrom
                let success := call( gas(), _contract, 0x00, 0x00, 0x64, 0x00, 0x00)

                if iszero(success) {
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0x00, returndatasize())
                }
            }
        }
    }
}