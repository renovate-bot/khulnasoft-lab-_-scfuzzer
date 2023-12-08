contract Foo {
    function f() public {}

    function scfuzzer_address() public returns (bool) {
        return address(this) == address(0x12342);
    }
}
