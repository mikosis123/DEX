// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract IQoutationFeatch {

    struct LiquidityPool {
        uint256 reserve0;
        uint256 reserve1;
        uint256 lowerBound;
        uint256 upperBound;
        mapping(address => uint256) providerAmounts;
    }

    mapping(bytes32 => LiquidityPool) public liquidityPools;

    // Function to get the price quote from a liquidity pool
    function getPriceQuote(bytes32 poolId) public view returns (uint256 price) {
        LiquidityPool storage pool = liquidityPools[poolId];
        require(pool.reserve0 > 0 && pool.reserve1 > 0, "Insufficient liquidity");

        price = (pool.reserve1 * 1e18) / pool.reserve0; // Assuming 18 decimals for simplicity
        require(price >= pool.lowerBound && price <= pool.upperBound, "Price out of range");
    }

    // Function to view the possible range for a quote
    function getPriceRange(bytes32 poolId) public view returns (uint256 lowerBound, uint256 upperBound) {
        LiquidityPool storage pool = liquidityPools[poolId];
        return (pool.lowerBound, pool.upperBound);
    }

    // Function to get the details of a pool provider
    function getProviderDetails(bytes32 poolId, address provider) public view returns (uint256 amountProvided) {
        LiquidityPool storage pool = liquidityPools[poolId];
        return pool.providerAmounts[provider];
    }

    // Function to fetch the latest price from Chainlink PriceFeeds
    function getChainlinkPrice(address aggregator) public view returns (int256 price, uint8 decimals) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(aggregator);
        (, price, , , ) = priceFeed.latestRoundData();
        decimals = priceFeed.decimals();
    }
}
