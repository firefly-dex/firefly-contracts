// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import './pool/IFireflyV3PoolImmutables.sol';
import './pool/IFireflyV3PoolState.sol';
import './pool/IFireflyV3PoolDerivedState.sol';
import './pool/IFireflyV3PoolActions.sol';
import './pool/IFireflyV3PoolOwnerActions.sol';
import './pool/IFireflyV3PoolEvents.sol';

/// @title The interface for a Firefly V3 Pool
/// @notice A Firefly pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IFireflyV3Pool is
    IFireflyV3PoolImmutables,
    IFireflyV3PoolState,
    IFireflyV3PoolDerivedState,
    IFireflyV3PoolActions,
    IFireflyV3PoolOwnerActions,
    IFireflyV3PoolEvents
{

}
