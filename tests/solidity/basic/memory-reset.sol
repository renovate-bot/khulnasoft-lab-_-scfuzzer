contract ShouldNotRevert {	
  function f() public { }

   function scfuzzer_memory() public returns (bool) {	
    bool[] memory includeMap = new bool[](1);	
    if (includeMap[0]) {	
      revert();	
    }	
    return true;	
  }	
}
