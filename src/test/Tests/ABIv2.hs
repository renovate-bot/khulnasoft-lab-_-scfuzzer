module Tests.ABIv2 (abiv2Tests) where

import Test.Tasty (TestTree, testGroup)

import Common (testContract, solved)

abiv2Tests :: TestTree
abiv2Tests = testGroup "ABIv2 tests"
  [ 
    testContract "abiv2/Ballot.sol"       Nothing
      [ ("scfuzzer_test passed",                    solved      "scfuzzer_test") ]
  , testContract "abiv2/Dynamic.sol"      Nothing
      [ ("scfuzzer_test passed",                    solved      "scfuzzer_test") ]
  , testContract "abiv2/Dynamic2.sol"     Nothing
      [ ("scfuzzer_test passed",                    solved      "scfuzzer_test") ]
  , testContract "abiv2/MultiTuple.sol"   Nothing
      [ ("scfuzzer_test passed",                    solved      "scfuzzer_test") ]

  ]
