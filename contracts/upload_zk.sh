echo "📤 Deploying ZK contract..."
forge create contracts/verifier.sol:Groth16Verifier \
    --rpc-url https://testnet-passet-hub-eth-rpc.polkadot.io \
    --private-key 0xbf91748f1b1ba198bb767e6a5658bd35d1118f937e6e87100b664f8f68184642 \
    --resolc --broadcast --via-ir -Oz -vvvvv
