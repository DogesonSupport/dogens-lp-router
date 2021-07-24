pragma solidity =0.6.6;

import './interfaces/IDogesonPancakeRouter.sol';
import './interfaces/IPancakeRouter02.sol';
import './libraries/TransferHelper.sol';

contract DogesonPancakeRouter is IDogesonPancakeRouter {
    address public immutable override router;
    address public immutable override WETH;
    
    IPancakeRouter02 internal pancakeRouter;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'DogesonPancakeRouter: EXPIRED');
        _;
    }
  
    // important to receive ETH
    receive() payable external {}

    constructor(
        address _router,
        address _WETH) public {
        router = _router;
        WETH = _WETH;

        pancakeRouter = IPancakeRouter02(_router);
    }

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'DogesonLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'DogesonLibrary: ZERO_ADDRESS');
    }

    // **** SWAP (V1) ****
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    { // we have to set the amount as the allowance of this contract(=address(this)) over the source token(=path[0]) before swapping
        require(path[0] == WETH || path[path.length - 1] == WETH, 'DogesonPancakeRouter: INVALID_PATH');

        TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), amountIn);
        TransferHelper.safeApprove(path[0], address(router), amountIn);

        amounts = pancakeRouter.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        override
        ensure(deadline)
    {
        require(path[0] == WETH || path[path.length - 1] == WETH, 'DogesonPancakeRouter: INVALID_PATH');

        TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), amountIn);
        TransferHelper.safeApprove(path[0], address(router), amountIn);

        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );
    }
}
