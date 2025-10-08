// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./vinterface.sol"; // import interface to deployed contract


contract PolkadotDemo {

    IGroth16Verifier public immutable verifier;


    // runs once at deployment
  constructor() {
        verifier = IGroth16Verifier(0x00D124b363e7F278aEFF220398254EdE169D307c); // paste address of deployed 
  }

    event DidSomething(bool myresult); // trigger event if guuud
    event NewUserMessage(bytes32 usermessage);


  /**
     * @dev take zk input data and verify it
     */
    function dosomething(      uint256[2] calldata _pA,
        uint256[2][2] calldata _pB,
        uint256[2] calldata _pC,
        uint256[3] calldata _pubSignals, bytes32 emitme) external {


        // Verify proof
        require(verifier.verifyProof(_pA, _pB, _pC, _pubSignals), "Invalid proof");
    
        emit NewUserMessage(emitme);

        emit DidSomething(true);
    }

}