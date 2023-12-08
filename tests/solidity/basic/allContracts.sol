contract A{
    bool public bug = true;
    function trigger_bug() public{
        bug = false;
    }
}
contract B{
    A public a;
    constructor() public{
        a = new A();
    }
    function scfuzzer_test() public returns(bool){
        return a.bug();
    }
}
