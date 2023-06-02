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
    /// @dev !! unsafe !!
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
                mstore(0x00, 0x383462e2)
                revert(0x1c, 0x04)
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
                mstore(0x00, 0x543bf3c4)
                revert(0x1c, 0x04)
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


    // ************************************* WenTokens Functions **************************************** //

    function airdropETH(
        address[] calldata _recipients,
        uint256[] calldata _amounts
    ) external payable {
        // looop through _recipients
        assembly {
            // store runningTotal
            // LCFR - not quite sure why this is needed
            let runningTotal := 0
            // store length of _recipients
            let sz := _amounts.length
            for {
                let i := 0
            } lt(i, sz) {
                // increment i
                i := add(i, 1)
            } {
                // store offset for _amounts[i]
                let offset := mul(i, 0x20)
                // store _amounts[i]
                // LCFR - (bug) if _amounts[] is longer than _recipients[] then this will send ETH to the null address?
                let amt := calldataload(add(_amounts.offset, offset))
                // store _recipients[i]
                // LCFR - (bug) if _recipients[] is longer than _amounts[] then this will send a 0 ETH transfer to the last recipient 
                let recp := calldataload(add(_recipients.offset, offset))
                // send _amounts[i] to _recipients[i]
                let success := call(
                    gas(),
                    recp, // address
                    amt, // amount
                    0,
                    0,
                    0,
                    0
                )
                // revert if call fails
                if iszero(success) {
                    revert(0, 0)
                }
                // add _amounts[i] to runningTotal
                runningTotal := add(runningTotal, amt)
            }
            // revert if runningTotal != msg.value
            if iszero(eq(runningTotal, callvalue())) {
                revert(0, 0)
            }
        }
    }

    function airdropETHLCFR(
        address[] calldata _recipients,
        uint256[] calldata _amounts
    ) external payable {
        // looop through _recipients
        assembly {
            // lcfr - doesnt prevent sending ETH to the null address if mismatched array lengths?
            // store runningTotal
            // let runningTotal := 0

            // lcfr - it cost more to cache the lengths of the arrays using assembly
            // store length of _recipients
            // let sz := _amounts.length

            // store the length of _amounts
            // let sx := _recipients.length

            // lcfr - check if the arrays are the same length
            // fix for array length bug. 
            if iszero(eq(_recipients.length, _amounts.length)) {
                mstore(0x00, 0x543bf3c4)
                revert(0x1c, 0x04)
            }
            // do this initialization outside of the loop declarations
            let i := 0
            // +1 after each loop iteration
            for {} 1 { i:= add(i, 1) } {
                // break from the loop if i == _recipients.length
                if eq(i, _recipients.length){ break }

                // store offset for both arrays
                // lcfr - use shl vs mul
                let offset := shl(5, i)

                // store _amounts[i]
                let amt := calldataload(add(_amounts.offset, offset))
                // store _recipients[i]
                let recp := calldataload(add(_recipients.offset, offset))
                // send _amounts[i] to _recipients[i]
                let success := call(
                    gas(),
                    recp, // address
                    amt, // amount
                    0,
                    0,
                    0,
                    0
                )
                // revert if call fails
                if iszero(success) {
                    // y tho?
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0, 0)
                }
                // lcfr - dunno what this was for
                // add _amounts[i] to runningTotal
                // runningTotal := add(runningTotal, amt)
            }

            // revert if runningTotal != msg.value
            // if iszero(eq(runningTotal, callvalue())) {
                
            // lcfr - if contract balance is > 0 something went wrong. 
            if gt(selfbalance(), 0) {
                // do custom error
                revert(0, 0)
            }
        }
    }

    /**
     *
     * @param _token ERC20 token to airdrop
     * @param _recipients list of recipients
     * @param _amounts list of amounts to send each recipient
     * @param _total total amount to transfer from caller
     */
    function airdropERC20(
        IERC20 _token,
        address[] calldata _recipients,
        uint256[] calldata _amounts,
        uint256 _total
    ) external {
        // bytes selector for transferFrom(address,address,uint256)
        bytes4 transferFrom = 0x23b872dd;
        // bytes selector for transfer(address,uint256)
        bytes4 transfer = 0xa9059cbb;

        assembly {
            // store transferFrom selector
            let transferFromData := add(0x20, mload(0x40))
            mstore(transferFromData, transferFrom)
            // store caller address
            mstore(add(transferFromData, 0x04), caller())
            // store address
            mstore(add(transferFromData, 0x24), address())
            // store _total
            mstore(add(transferFromData, 0x44), _total)
            // call transferFrom for _total
            let successTransferFrom := call(
                gas(),
                _token,
                0,
                transferFromData,
                0x64,
                0,
                0
            )
            // revert if call fails
            if iszero(successTransferFrom) {
                revert(0, 0)
            }

            // store transfer selector
            let transferData := add(0x20, mload(0x40))
            mstore(transferData, transfer)

            // store length of _recipients
            let sz := _amounts.length

            // loop through _recipients
            for {
                let i := 0
            } lt(i, sz) {
                // increment i
                i := add(i, 1)
            } {
                // store offset for _amounts[i]
                let offset := mul(i, 0x20)
                // store _amounts[i]
                let amt := calldataload(add(_amounts.offset, offset))
                // store _recipients[i]
                let recp := calldataload(add(_recipients.offset, offset))
                // store _recipients[i] in transferData
                mstore(
                    add(transferData, 0x04),
                    recp
                )
                // store _amounts[i] in transferData
                mstore(
                    add(transferData, 0x24),
                    amt
                )
                // call transfer for _amounts[i] to _recipients[i]
                let successTransfer := call(
                    gas(),
                    _token,
                    0,
                    transferData,
                    0x44,
                    0,
                    0
                )
                // revert if call fails
                if iszero(successTransfer) {
                    revert(0, 0)
                }  
            }
        }
    }

    function airdropERC20LCFR(
        address _token,
        address[] calldata _recipients,
        uint256[] calldata _amounts, 
        uint256 _total
    ) external {
        assembly {
            if iszero(eq(_recipients.length, _amounts.length)) {
                mstore(0x00, 0x543bf3c4)
                revert(0x1c, 0x04)
            }

            let transferFrom := 0x23b872ddac1db17cac1db17cac1db17cac1db17cac1db17cac1db17cac1db17c

            mstore(0x00, transferFrom)
            // store the caller as the first parameter to transferFrom()
            mstore(0x04, caller())
            // store the contract address as the second parameter to transferFrom()
            mstore(0x24, address())
            // store the total amount to transfer as the third parameter to transferFrom()
            mstore(0x44, _total)

            let successTransferFrom := call(
                gas(),
                _token,
                0,
                0,
                0x64,
                0,
                0
            )

            // revert if call fails
            if iszero(successTransferFrom) {
                revert(0, 0)
            }

            // store the transfer selector at 0x00
            let transfer := 0xa9059cbbac1db17cac1db17cac1db17cac1db17cac1db17cac1db17cac1db17c
            mstore(0x00, transfer)
            // store the recipient as the first parameter to transfer()
            let i := 0
            for {} 1 { i:= add(i, 1) } {
                if eq(i, _recipients.length){ break }

                // store offset for _amounts[i]
                // let offset := mul(i, 0x20)
                let offset := shl(5, i)

                calldatacopy(0x04, add(_recipients.offset, offset), 0x20)

                calldatacopy(0x24, add(_amounts.offset, offset), 0x20)

                let successTransfer := call(
                    gas(),
                    _token,
                    0,
                    0,
                    0x44,
                    0,
                    0
                )

                // revert if call fails
                if iszero(successTransfer) {
                    revert(0, 0)
                }  
            }
        }
    }

    // test with transferFrom then transfer logic next?



    // ************************************* Disperse Functions ***************************************** //
    function disperseToken(
        IERC20 token,
        address[] memory recipients,
        uint256[] memory values
    ) external {
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++) total += values[i];
        require(token.transferFrom(msg.sender, address(this), total));
        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]));
    }

}