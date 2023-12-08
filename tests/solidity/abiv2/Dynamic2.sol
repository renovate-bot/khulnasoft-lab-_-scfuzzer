contract Dynamic {
  bool cond = true;

  function yolo(uint256 x, string memory s, uint256 y) public returns (bool) {
    if (keccak256(abi.encodePacked(s)) == keccak256(abi.encodePacked("yolo"))) {
      cond = false;
    }
    return(true);
  }

  function scfuzzer_test() public returns (bool) {
    return(cond);
  }
}
