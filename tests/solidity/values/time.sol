contract Time {
  uint start;
  uint marked;

  constructor() public {
    start  = block.timestamp;
    marked = block.timestamp;
  }

  function mark() public {
    marked = block.timestamp;
  }

  function scfuzzer_timepassed() public returns (bool) {
    return(start == marked);
  }

  function scfuzzer_moretimepassed() public returns (bool) {
    return(block.timestamp < start + 10 weeks );
  }

}
