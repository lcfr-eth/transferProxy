// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/// @author lcfr.eth
/// @notice helper contract for Flashbots rescues using bundler.lcfr.io

contract transferProxy {

    error notApproved();

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
            
            if iszero(success) {
                revert(0x00, returndatasize())
            }
            
            if iszero(mload(0x00)) {
                mstore(0x00, shl(224, 0x383462e29))
                revert(0x00, 0x04)
            }

            let i := 0
            for {} 1 { i:= add(i, 1) } {
                if eq(i, _data.length){ break }

                let data := calldataload(add(_data.offset, shl(5, i)))
                let len := calldataload(add(_data.offset, data))

                calldatacopy(0x00, add(_data.offset, add(data, 0x20)), len)
                        
                success := call( gas(), _contract, 0x00, 0x00, len, 0x00, 0x00)

                if iszero(success) {
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0x00, returndatasize())
                }
            }
        }
    }
      function ownerDrop(uint256[] calldata tokenIds, address[] calldata _addrs, address _contract) external {
        bytes4 transferFrom = 0x23b872dd;
        assembly {

            // check the arrays are equal length
            if iszero(eq(mload(tokenIds), mload(_addrs))) {
                revert(0x00, 0x00)
            }

            // let transferFrom := 0x23b872dd00000000000000000000000000000000000000000000000000000000
            // let transferFrom := 0x23b872ddac1db17cac1db17cac1db17cac1db17cac1db17cac1db17cac1db17c

            mstore(0x00, transferFrom) // transferFrom(address,address,uint256)
            mstore(0x04, caller())

             let i := 0
             for {} 1 { i:= add(i, 1) } {
                if eq(i, tokenIds.length){ break }

                // offset for both arrays
                let offset := add(_addrs.offset, shl(5, i))

                // copy the address to send to
                calldatacopy(0x24, add(_addrs.offset, offset), 0x20)

                // copy the token id
                calldatacopy(0x44, add(tokenIds.offset, offset), 0x20)
                
                // call transferFrom
                success := call( gas(), _contract, 0x00, 0x00, 0x64, 0x00, 0x00)

                if iszero(success) {
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0x00, returndatasize())
                }
            }
        }
    }
}