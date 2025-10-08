echo "📤 Deploying FixedIlop contract..."
forge create src/main.sol:PolkadotDemo \
    --rpc-url https://testnet-passet-hub-eth-rpc.polkadot.io \
    --private-key 0xf07706918ef3fac8d5c1856010f470fecf15dca5b30a1ad1e5f8b3c022d8e997 \
    --resolc --broadcast --via-ir -Oz -vvvvv