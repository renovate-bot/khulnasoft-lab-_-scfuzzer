contract C {
  bool state = true;
  function f() public {
    D a = new D();
    D b = new D();
    state = false;
  }

  function scfuzzer_construct() public returns (bool) {
    return state;
  }
}

contract D {}
