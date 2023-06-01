// SPDX-License-Identifier: MiladyCometh
pragma solidity ^0.8.17;

/// @author lcfr.eth
/// @notice helper contract for Flashbots rescues using bundler.lcfr.io
/// @dev :PpPPpPPppPPpPPpPPpP

contract transferProxy {

    error notApproved();
    error arrayLengthMismatch();

    // transfers a batch of ERC721 tokens to a single address recipient from an approved caller address
    function ApprovedTransferERC721(uint256[] calldata tokenIds, address _contract, address _from, address _to) external {
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

            // build calldata using the _from and _to thats supplied as an argument
            // transferFrom(address,address,uint256) selector
            let transferFrom := 0x23b872ddac1db17cac1db17cac1db17cac1db17cac1db17cac1db17cac1db17c
            // store the selector at 0x00
            mstore(0x00, transferFrom)
            // store the caller as the first parameter to transferFrom()
            mstore(0x04, _from)
            // store _to as the second parameter to transferFrom()
            mstore(0x24, _to)

            // start our loop at 0
            let i := 0
            for {} 1 { i:= add(i, 1) } {
                // check if we have reached the end of the array. _data len starts at 1
                if eq(i, tokenIds.length){ break }

                // copy the token id as the third parameter to transferFrom()
                calldatacopy(0x44, add(tokenIds.offset, shl(5, i)), 0x20)

                // call the encoded method        
                success := call( gas(), _contract, 0x00, 0x00, 0x64, 0x00, 0x00)

                if iszero(success) {
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0x00, returndatasize())
                }
            }
        }
    }

    /// @notice transfer assets from the owner to the _to address
    function ownerTransferERC721(uint256[] calldata tokenIds, address _to, address _contract) external {
        assembly {
            // maybe use safeTransferFrom? or nahh
            // transferFrom(address,address,uint256) selector
            let transferFrom := 0x23b872ddac1db17cac1db17cac1db17cac1db17cac1db17cac1db17cac1db17c
            // store the selector at 0x00
            mstore(0x00, transferFrom)
            // store the caller as the first parameter to transferFrom()
            mstore(0x04, caller())
            // store _to as the second parameter to transferFrom()
            mstore(0x24, _to)

             let i := 0
             for {} 1 { i:= add(i, 1) } {
                if eq(i, tokenIds.length){ break }

                // copy the token id as the third parameter to transferFrom()
                calldatacopy(0x44, add(tokenIds.offset, shl(5, i)), 0x20)
                
                // call transferFrom
                let success := call( gas(), _contract, 0x00, 0x00, 0x64, 0x00, 0x00)

                if iszero(success) {
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0x00, returndatasize())
                }
            }
        }
    }

    /// @notice intended for transferring an array of tokens to an array of addresses from the owner
    function ownerAirDropERC721(uint256[] calldata tokenIds, address[] calldata _addrs, address _contract) external {
        assembly {
            // check if the arrays are the same length
            if iszero(eq(tokenIds.length, _addrs.length)) {
                mstore(0x00, shl(224, 0x543bf3c4))
                revert(0x00, 0x04)
            }
            // maybe use safeTransferFrom? or nahh
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

    function ownerAirDropERC1155() external {}
    // ApprovedTransferERC1155 can be done via the ERC1155 safeBatchTransferFrom() function in the UI
    // OwnerTransferERC1155 can be done via the ERC1155 safeBatchTransferFrom() function in the UI


}