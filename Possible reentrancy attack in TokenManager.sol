Possible reentrancy attack in TokenManager.sol

0bingo76
Summary
The withdraw() function in the TokenManager contract is vulnerable to reentrancy attacks. The function updates the user’s balance after transferring tokens, allowing an attacker to potentially drain more funds than they should be entitled to.

Vulnerability Details
In the provided withdraw() function, the token transfer is executed before the user’s balance is updated:

https://github.com/Cyfrin/2024-08-tadle/blob/04fd8634701697184a3f3a5558b41c109866e5f8/src/core/TokenManager.sol#L137-L209

The vulnerability lies in the fact that the userTokenBalanceMap is not updated before the token transfer occurs. This allows an attacker to potentially call the withdraw() function multiple times before their balance is set to zero

Impact
An attacker could potentially drain more tokens than they are entitled to, leading to significant financial losses for the protocol and its users

Tools Used
maual code review

Recommendations
To mitigate this vulnerability, follow the Checks-Effects-Interactions (CEI) pattern. Update the user’s balance before making any external calls. This change ensures that the user’s balance is set to zero before any tokens are transferred, preventing reentrancy attacks.

Also consider adding a reentrancy guard. While the function already has a whenNotPaused modifier, an additional reentrancy guard can provide an extra layer of security.

We can revise the withdraw() function like so:

```solidity
function withdraw(
    address tokenAddress,
    TokenBalanceType tokenBalanceType
) external whenNotPaused {
    uint256 claimAbleAmount = userTokenBalanceMap[_msgSender()][
        tokenAddress
    ][tokenBalanceType];
    
    require(claimAbleAmount > 0, "No balance to withdraw");

    address capitalPoolAddr = tadleFactory.relatedContracts(
        RelatedContractLibraries.CAPITAL_POOL
    );

    // Update state before external call
    userTokenBalanceMap[_msgSender()][tokenAddress][tokenBalanceType] = 0;

    if (tokenAddress == wrappedNativeToken) {
        _transfer(
            wrappedNativeToken,
            capitalPoolAddr,
            address(this),
            claimAbleAmount,
            capitalPoolAddr
        );
        IWrappedNativeToken(wrappedNativeToken).withdraw(claimAbleAmount);
        payable(msg.sender).transfer(claimAbleAmount);
    } else {
        _safe_transfer_from(
            tokenAddress,
            capitalPoolAddr,
            _msgSender(),
            claimAbleAmount
        );
    }

    emit Withdraw(
        _msgSender(),
        tokenAddress,
        tokenBalanceType,
        claimAbleAmount
    );
}

```
