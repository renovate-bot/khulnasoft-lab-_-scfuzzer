contract Abstract {
  constructor(uint x) public {}
  function f() pure public {}
  function scfuzzer_f() pure public returns (bool) {return true;}
}
