contract C { 

  function scfuzzer_gaslimit() public returns (bool) {
    return block.gaslimit > 0;
  }

}
