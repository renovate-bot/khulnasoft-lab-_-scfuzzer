contract C {
  bool state;
  uint time;

  function set() public {
    time = block.timestamp;
  }

  function guess(uint x) public {
    if (x <= time + 4 weeks && x >= time - 4 weeks )
      state = true;
  }

  function scfuzzer_now() public returns(bool) {
    return (!state);
  }

} 
