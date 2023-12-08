module Tests.Values (valuesTests) where

import Test.Tasty (TestTree, testGroup)

import Common (testContract, testContract', solved, solvedLen)

valuesTests :: TestTree
valuesTests = testGroup "Value extraction tests"
  [ 
    testContract "values/nearbyMining.sol" Nothing
      [ ("scfuzzer_findNearby passed", solved "scfuzzer_findNearby") ]
    , testContract' "values/smallValues.sol" Nothing Nothing (Just "coverage/test.yaml") False
      [ ("scfuzzer_findSmall passed", solved "scfuzzer_findSmall") ]
    , testContract "values/constants.sol"    Nothing
      [ ("scfuzzer_found failed",                   solved      "scfuzzer_found")
      , ("scfuzzer_found_large failed",             solved      "scfuzzer_found_large") ]
    , testContract "values/constants2.sol"   Nothing
      [ ("scfuzzer_found32 failed",                 solved      "scfuzzer_found32") ]
    , testContract "values/constants3.sol"   Nothing
      [ ("scfuzzer_found_sender failed",            solved      "scfuzzer_found_sender") ]
    , testContract "values/rconstants.sol"   Nothing
      [ ("scfuzzer_found failed",                   solved      "scfuzzer_found") ]
    , testContract' "values/extreme.sol"   Nothing Nothing (Just "values/extreme.yaml") False
      [ ("testMinInt8 passed",                   solved      "testMinInt8"),
        ("testMinInt16 passed",                  solved      "testMinInt16"),
        ("testMinInt64 passed",                  solved      "testMinInt32"),
        ("testMinInt128 passed",                 solved      "testMinInt128")
      ]
    , testContract' "values/utf8.sol"   Nothing Nothing (Just "values/extreme.yaml") False
      [ ("testNonUtf8 passed",                   solved      "testNonUTF8")]
    , testContract' "values/create.sol" (Just "C") Nothing Nothing True
      [ ("scfuzzer_state failed",                   solved      "scfuzzer_state") ]
    , testContract "values/time.sol"         (Just "values/time.yaml")
      [ ("scfuzzer_timepassed passed",              solved      "scfuzzer_timepassed") ]
    , testContract "values/now.sol"          Nothing
      [ ("scfuzzer_now passed",                     solved      "scfuzzer_now") ]
    , testContract "values/large.sol"        Nothing
      [ ("scfuzzer_large failed",                   solved      "scfuzzer_large") ]
    ,  testContract "values/payable.sol"     Nothing
      [ ("scfuzzer_payable failed",                 solved      "scfuzzer_payable") ]
    , testContract "values/darray.sol"       Nothing
      [ ("scfuzzer_darray passed",                  solved      "scfuzzer_darray")
      , ("scfuzzer_darray didn't shrink optimally", solvedLen 1 "scfuzzer_darray") ]

  ]
