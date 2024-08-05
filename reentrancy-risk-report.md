# Reentrancy Risk Vulnerability

## Impact

High. The `stakeMunchable` function in the `LandManager` contract is vulnerable to reentrancy attacks. This could allow an attacker to manipulate the contract state in unexpected ways, potentially leading to theft of assets or permanent disruption of the contract's functionality.

## Proof of Concept (POC)

The vulnerability exists in the `stakeMunchable` function:

```solidity
function stakeMunchable(
    address landlord,
    uint256 tokenId,
    uint256 plotId
) external override forceFarmPlots(msg.sender) notPaused {
    // ... (earlier checks)
    
    munchNFT.transferFrom(mainAccount, address(this), tokenId);  // External call

    plotOccupied[landlord][plotId] = Plot({
        occupied: true,
        tokenId: tokenId
    });

    munchablesStaked[mainAccount].push(tokenId);
    munchableOwner[tokenId] = mainAccount;

    // ... (more state changes)
}
```

To exploit this:
1. An attacker creates a malicious ERC721 token contract that implements a `transferFrom` function which calls back into `stakeMunchable`.
2. The attacker calls `stakeMunchable` with their malicious token.
3. During the `transferFrom` call, the malicious contract calls back into `stakeMunchable`.
4. The second call to `stakeMunchable` passes all checks (as the first call hasn't completed its state changes yet) and proceeds to make another `transferFrom` call.
5. This process can repeat, allowing the attacker to stake multiple times with the same token or manipulate the contract state in other unexpected ways.

## Tools Used

Manual code review.

## Recommended Mitigation Steps

1. Implement the checks-effects-interactions pattern. Move the `transferFrom` call to the end of the function:

```solidity
function stakeMunchable(
    address landlord,
    uint256 tokenId,
    uint256 plotId
) external override forceFarmPlots(msg.sender) notPaused {
    // ... (earlier checks)

    plotOccupied[landlord][plotId] = Plot({
        occupied: true,
        tokenId: tokenId
    });

    munchablesStaked[mainAccount].push(tokenId);
    munchableOwner[tokenId] = mainAccount;

    // ... (other state changes)

    // Move the external call to the end
    munchNFT.transferFrom(mainAccount, address(this), tokenId);
}
```

2. Consider using OpenZeppelin's `ReentrancyGuard` contract:

```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LandManager is ReentrancyGuard, ... {
    // ...
    function stakeMunchable(...) external nonReentrant {
        // ... (function body)
    }
}
```

These changes will prevent reentrancy attacks by ensuring all state changes are completed before making any external calls, or by using a mutex to prevent recursive calls to the function.
