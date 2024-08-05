# Unchecked Token Transfer Vulnerability

## Impact

High. The `stakeMunchable` function in the `LandManager` contract performs an unchecked token transfer, which could lead to inconsistent contract state and potential loss of assets. If the transfer fails silently, the contract will continue execution as if the transfer was successful, potentially allowing users to stake tokens they don't actually own or transfer.

## Proof of Concept (POC)

The vulnerability exists in the `stakeMunchable` function:

```solidity
function stakeMunchable(
    address landlord,
    uint256 tokenId,
    uint256 plotId
) external override forceFarmPlots(msg.sender) notPaused {
    // ... (earlier checks)
    
    if (
        !munchNFT.isApprovedForAll(mainAccount, address(this)) &&
        munchNFT.getApproved(tokenId) != address(this)
    ) revert NotApprovedError();
    munchNFT.transferFrom(mainAccount, address(this), tokenId);  // Unchecked transfer
    
    // ... (state updates continue)
}
```

To exploit this:
1. A malicious user calls `stakeMunchable` with a `tokenId` they don't own.
2. The `transferFrom` call fails silently.
3. The contract continues execution, updating its state as if the transfer succeeded.
4. The attacker gains benefits of staking without actually transferring the token.

## Tools Used

Manual code review.

## Recommended Mitigation Steps

1. Use OpenZeppelin's `safeTransferFrom` function instead of `transferFrom`. This requires implementing the `IERC721Receiver` interface:

```solidity
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract LandManager is IERC721Receiver, ... {
    // ...
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
    function stakeMunchable(...) {
        // ...
        munchNFT.safeTransferFrom(mainAccount, address(this), tokenId);
        // ...
    }
}
```

2. Alternatively, if using `transferFrom`, wrap it in a `require` statement:

```solidity
require(
    munchNFT.transferFrom(mainAccount, address(this), tokenId),
    "Token transfer failed"
);
```

These changes ensure that the function will revert if the token transfer fails, maintaining consistent contract state and preventing potential exploits.
