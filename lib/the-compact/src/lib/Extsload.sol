// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title Extsload
 * @notice Contract implementing external functions for reading values from
 * storage or transient storage directly.
 */
contract Extsload {
    /**
     * @notice External view function for reading a value from transient storage.
     * @param slot The storage slot to read from.
     * @return The value stored in the specified transient storage slot.
     */
    function exttload(bytes32 slot) external view returns (bytes32) {
        assembly ("memory-safe") {
            mstore(0, tload(slot))
            return(0, 0x20)
        }
    }

    /**
     * @notice External view function for reading a value from persistent storage.
     * @param slot The storage slot to read from.
     * @return The value stored in the specified persistent storage slot.
     */
    function extsload(bytes32 slot) external view returns (bytes32) {
        assembly ("memory-safe") {
            mstore(0, sload(slot))
            return(0, 0x20)
        }
    }

    /**
     * @notice External view function for reading multiple values from persistent storage.
     * @param slots An array of storage slots to read from.
     * @return An array of values stored in the specified persistent storage slots.
     */
    function extsload(bytes32[] calldata slots) external view returns (bytes32[] memory) {
        assembly ("memory-safe") {
            let memptr := mload(0x40)
            let start := memptr
            // For abi encoding the response - the array will be found at 0x20.
            mstore(memptr, 0x20)
            // Next, store the length of the return array.
            mstore(add(memptr, 0x20), slots.length)
            // Update memptr to the first location to hold an array entry.
            memptr := add(memptr, 0x40)
            // A left bit-shift of 5 is equivalent to multiplying by 32 but costs less gas.
            let end := add(memptr, shl(5, slots.length))
            let calldataptr := slots.offset
            for { } 1 { } {
                mstore(memptr, sload(calldataload(calldataptr)))
                memptr := add(memptr, 0x20)
                if iszero(lt(memptr, end)) { break }
                calldataptr := add(calldataptr, 0x20)
            }
            return(start, sub(end, start))
        }
    }
}
