pragma solidity >=0.5.0;

interface IFireflyV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    event UpdateProtocolFee(address indexed pair, uint newFee, uint oldFee);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function updateProtocolFee(address pair, uint value) external;
    function getProtocolFee(address pair) external view returns (uint);
}
