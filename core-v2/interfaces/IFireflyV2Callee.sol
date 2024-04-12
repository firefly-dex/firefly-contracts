pragma solidity >=0.5.0;

interface IFireflyV2Callee {
    function fireflyV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}
