module Tests.Cheat (cheatTests) where

import Test.Tasty (TestTree, testGroup)

import Common (testContract', solcV, solved)

cheatTests :: TestTree
cheatTests =
  testGroup "Cheatcodes Tests"
    [ testContract' "cheat/ffi.sol" (Just "TestFFI") (Just (> solcV (0,6,0))) (Just "cheat/ffi.yaml") False
        [ ("scfuzzer_ffi passed", solved "scfuzzer_ffi") ]
    ]
