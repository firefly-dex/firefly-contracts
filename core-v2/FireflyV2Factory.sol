pragma solidity =0.5.16;

import './interfaces/IFireflyV2Factory.sol';
import './interfaces/IFireflyV2Pair.sol';
import './FireflyV2Pair.sol';

contract FireflyV2Factory is IFireflyV2Factory {
    address public feeTo;
    address public feeToSetter;

    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(FireflyV2Pair).creationCode));

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    event UpdateProtocolFee(address indexed pair, uint newFee, uint oldFee);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function getProtocolFee(address pair) external view returns (uint) {
        return IFireflyV2Pair(pair).getFeePercentage();
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'FireflyV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'FireflyV2: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'FireflyV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(FireflyV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IFireflyV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'FireflyV2: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'FireflyV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function updateProtocolFee(address pair, uint value) external {
        require(msg.sender == feeToSetter, 'FireflyV2: FORBIDDEN');
        uint protocolFee = IFireflyV2Pair(pair).getFeePercentage();
        require(protocolFee != value, 'FireflyV2: SAME_VALUE');
        // setting fee to 60000 would mean zero fees for LPs
        // anything above this value would take from their provided liqudity
        require(value < 60000, 'FireflyV2: FORBIDDEN');
        IFireflyV2Pair(pair).updateFeePercentage(value);
        emit UpdateProtocolFee(pair, value, protocolFee);
    }
}
