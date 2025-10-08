#!/bin/bash

# --- Circuit Compilation ---
echo "Step 1: Compiling circuit..."
circom 1337.circom --r1cs --wasm --sym --c || { echo "Circuit compilation failed!"; exit 1; }

# --- Circuit Information and Powers of Tau Calculation ---
echo "Checking circuit size..."
R1CS_INFO=$(snarkjs r1cs info 1337.r1cs)
CONSTRAINTS=$(echo "$R1CS_INFO" | awk '/Constraints:/ {print $2}')
echo "Circuit constraints: $CONSTRAINTS"

# Calculate required Powers of Tau size (2^n > constraints*2)
POT_SIZE=18  # Starting with a reasonable default
while [ $((2**POT_SIZE)) -le $((CONSTRAINTS*2)) ]; do
  ((POT_SIZE++))
done
echo "Using Powers of Tau size: $POT_SIZE (2^$POT_SIZE = $((2**POT_SIZE)))"

# --- Input File Generation ---
echo "Step 2: Generating input file..."
cd 1337_js/ || { echo "Could not enter 1337_js directory!"; exit 1; }

# Generate input for AddElite circuit: a and b are public inputs
cat <<EOF > input.json
{
  "a": "10",
  "b": "20"
}
EOF
echo "Input file input.json created (a=10, b=20, expected output: 1367)."

# --- Witness Generation ---
echo "Step 3: Generating witness..."
node generate_witness.js 1337.wasm input.json witness.wtns || { echo "Witness generation failed!"; exit 1; }
echo "Witness generated successfully."
cd ..

# --- Powers of Tau Ceremony ---
echo "Step 4: Starting Powers of Tau ceremony (size $POT_SIZE)..."
snarkjs powersoftau new bn128 $POT_SIZE pot${POT_SIZE}_0000.ptau -v || { echo "Powers of Tau 'new' failed!"; exit 1; }
snarkjs powersoftau contribute pot${POT_SIZE}_0000.ptau pot${POT_SIZE}_0001.ptau --name="First contribution" -v -e="random text for first contribution" || { echo "Powers of Tau 'contribute' failed!"; exit 1; }
snarkjs powersoftau prepare phase2 pot${POT_SIZE}_0001.ptau pot${POT_SIZE}_final.ptau -v || { echo "Powers of Tau 'prepare phase2' failed!"; exit 1; }
echo "Powers of Tau ceremony completed."

# --- Groth16 Setup ---
echo "Step 5: Generating zkey..."
snarkjs groth16 setup 1337.r1cs pot${POT_SIZE}_final.ptau 1337_0000.zkey || { echo "Groth16 setup failed!"; exit 1; }
snarkjs zkey contribute 1337_0000.zkey 1337_0001.zkey --name="Second contribution" -v -e="more random text for second contribution" || { echo "zkey contribute failed!"; exit 1; }
snarkjs zkey export verificationkey 1337_0001.zkey verification_key.json || { echo "Verification key export failed!"; exit 1; }
echo "Zkey and verification key generated."

# --- Proof Generation ---
echo "Step 6: Generating proof..."
snarkjs groth16 prove 1337_0001.zkey 1337_js/witness.wtns 1337_js/proof.json 1337_js/public.json || { echo "Proof generation failed!"; exit 1; }
echo "Proof generated successfully."

# --- Verifier Contract Generation ---
echo "Step 7: Generating verifier contract..."
snarkjs zkey export solidityverifier 1337_0001.zkey verifier.sol || { echo "Verifier contract generation failed!"; exit 1; }
echo "Verifier contract verifier.sol created."

# --- Call Data Generation ---
echo "Step 8: Generating call data..."
snarkjs generatecall 1337_js/public.json 1337_js/proof.json || { echo "Call data generation failed!"; exit 1; }
echo "Call data generated."

echo "--- Process completed successfully! ---"
echo "Verifier contract: verifier.sol"

