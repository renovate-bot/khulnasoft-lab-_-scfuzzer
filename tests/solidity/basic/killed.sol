contract C {

  uint private state = 0;
  function f(uint x) public {
    state = x;
  }

  function kill_me() public {
    require(state > 256);
    selfdestruct(msg.sender);
  }

  function scfuzzer_still_alive() public returns (bool) {
    return true;
  }

  function scfuzzer_revert_still_alive() public returns (bool) {
    revert();
  }

}
