// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

import './interfaces/IFireflyV3Factory.sol';

import './FireflyV3PoolDeployer.sol';
import './NoDelegateCall.sol';

import './FireflyV3Pool.sol';

/// @title Canonical Firefly V3 factory
/// @notice Deploys Firefly V3 pools and manages ownership and control over pool protocol fees
contract FireflyV3Factory is IFireflyV3Factory, FireflyV3PoolDeployer, NoDelegateCall {
    /// @inheritdoc IFireflyV3Factory
    address public override owner;

    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(FireflyV3Pool).creationCode));

    /// @inheritdoc IFireflyV3Factory
    mapping(uint24 => int24) public override feeAmountTickSpacing;
    /// @inheritdoc IFireflyV3Factory
    mapping(address => mapping(address => mapping(uint24 => address))) public override getPool;

    mapping(address => mapping(address => uint24)) private pairWhitelist;

    constructor() {
        owner = msg.sender;
        emit OwnerChanged(address(0), msg.sender);

        feeAmountTickSpacing[500] = 10;
        emit FeeAmountEnabled(500, 10);
        feeAmountTickSpacing[3000] = 60;
        emit FeeAmountEnabled(3000, 60);
        feeAmountTickSpacing[10000] = 200;
        emit FeeAmountEnabled(10000, 200);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// @inheritdoc IFireflyV3Factory
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external override noDelegateCall returns (address pool) {
        require(tokenA != tokenB);
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0));
        int24 tickSpacing = feeAmountTickSpacing[fee];
        require(tickSpacing != 0);
        require(getPool[token0][token1][fee] == address(0));
        uint24 _allowedFee = pairWhitelist[token0][token1];
        if (_allowedFee != 0) {
            require(_allowedFee == fee);
        }
        pool = deploy(address(this), token0, token1, fee, tickSpacing);
        getPool[token0][token1][fee] = pool;
        // populate mapping in the reverse direction, deliberate choice to avoid the cost of comparing addresses
        getPool[token1][token0][fee] = pool;
        emit PoolCreated(token0, token1, fee, tickSpacing, pool);
    }

    /// @inheritdoc IFireflyV3Factory
    function setOwner(address _owner) external override onlyOwner {
        emit OwnerChanged(owner, _owner);
        owner = _owner;
    }

    /// @inheritdoc IFireflyV3Factory
    function enableFeeAmount(uint24 fee, int24 tickSpacing) public override onlyOwner {
        require(fee < 1000000);
        // tick spacing is capped at 16384 to prevent the situation where tickSpacing is so large that
        // TickBitmap#nextInitializedTickWithinOneWord overflows int24 container from a valid tick
        // 16384 ticks represents a >5x price change with ticks of 1 bips
        require(tickSpacing > 0 && tickSpacing < 16384);
        require(feeAmountTickSpacing[fee] == 0);

        feeAmountTickSpacing[fee] = tickSpacing;
        emit FeeAmountEnabled(fee, tickSpacing);
    }

    /// @inheritdoc IFireflyV3Factory
    function whitelistPair(address tokenA, address tokenB, uint24 fee) external override onlyOwner {
        require(pairWhitelist[tokenA][tokenB] != fee);
        // populate fees in both directions
        pairWhitelist[tokenA][tokenB] = fee;
        pairWhitelist[tokenB][tokenA] = fee;
        emit WhitelistPair(tokenA, tokenB, fee);
    }

    /// @inheritdoc IFireflyV3Factory
    function getPairWhitelist(address tokenA, address tokenB) external view override returns (uint24 fee) {
        fee = pairWhitelist[tokenA][tokenB];
    }
}
