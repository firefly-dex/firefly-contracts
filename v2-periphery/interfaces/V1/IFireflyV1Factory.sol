pragma solidity >=0.5.0;

interface IFireflyV1Factory {
    function getExchange(address) external view returns (address);
}
