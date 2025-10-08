pragma circom 2.0.0;

template AddElite() {
    signal input a;
    signal input b;
    signal output out;
    
    // Add both inputs and 1337 in one operation
    out <== a + b + 1337;
}

component main {public [a, b]} = AddElite(); // define the input the user will give for example a=10, b=20, calculation will be 10+20+1337
