# Remix IDE Instructions for Proxy Vulnerability PoC

Follow these steps to deploy and test the Proxy Vulnerability PoC using Remix IDE:

1. **Open Remix IDE**
   - Go to https://remix.ethereum.org in your web browser.

2. **Create a New File**
   - Click on the "+" icon in the file explorer (left sidebar).
   - Name the file `ProxyVulnerability.sol`.

3. **Paste the Code**
   - Copy the entire Solidity code from the previous message.
   - Paste it into the `ProxyVulnerability.sol` file in Remix.

4. **Compile the Code**
   - Go to the "Solidity Compiler" tab (usually the second icon in the left sidebar).
   - Make sure the compiler version is set to 0.8.0 or higher.
   - Click "Compile ProxyVulnerability.sol".

5. **Deploy the Contract**
   - Go to the "Deploy & Run Transactions" tab (usually the third icon in the left sidebar).
   - In the "Contract" dropdown, select "ProxyVulnerabilityTest".
   - Click "Deploy".

6. **Interact with the Contract**
   - After deployment, you'll see the contract instance appear under "Deployed Contracts".
   - Expand it to see all available functions.

7. **Set Up the Initial State**
   - Click on "setupInitialImplementation" to set up the initial implementation.

8. **Set the Attacker**
   - In the "setAttacker" function input, enter an address you want to use as the attacker.
   - This can be any address except the one you used to deploy the contract.
   - Click "transact" to set the attacker.

9. **Switch Accounts**
   - In the "Account" dropdown at the top of the "Deploy & Run Transactions" tab, select a different account to act as the attacker.

10. **Exploit the Vulnerability**
    - With the attacker account selected, click on "exploitVulnerability".
    - This simulates the attacker exploiting the vulnerability in the Proxy contract.

11. **Verify the Exploit**
    - Click on "verifyExploit". It should return `true` if the exploit was successful.

12. **Check the Proxy Implementation**
    - Expand the "proxy" variable in the deployed contract.
    - Click on "implementation" to see the current implementation address.
    - It should now be the address of the MaliciousImplementation contract.

13. **Additional Verification (Optional)**
    - You can deploy the MaliciousImplementation contract separately.
    - Call the "attacker" function on this contract to verify that it returns the address you set as the attacker.

Remember, in a real-world scenario, this vulnerability would allow an attacker to take control of the proxy contract, potentially leading to loss of funds or other malicious actions. This PoC demonstrates why proper access control is crucial in upgradeable contracts.
