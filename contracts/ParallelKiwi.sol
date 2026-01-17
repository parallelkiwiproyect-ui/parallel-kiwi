// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/*
 Parallel Kiwi (PKIW)
 Fixed supply ERC20
 No mint after deploy
 No external dependencies
*/

contract ParallelKiwi {
    // --- ERC20 metadata ---
    string public constant name = "Parallel Kiwi";
    string public constant symbol = "PKIW";
    uint8 public constant decimals = 18;

    uint256 public constant totalSupply = 100_000_000_000 * 10**18;

    // --- ownership ---
    address public owner;

    // --- balances & allowances ---
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // --- events ---
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipRenounced(address indexed previousOwner);

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // --- ERC20 logic ---
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= amount, "ALLOWANCE_TOO_LOW");

        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - amount;
        }

        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "ZERO_ADDRESS");
        uint256 bal = balanceOf[from];
        require(bal >= amount, "BALANCE_TOO_LOW");

        unchecked {
            balanceOf[from] = bal - amount;
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    // --- ownership ---
    function renounceOwnership() external {
        require(msg.sender == owner, "NOT_OWNER");
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
}
