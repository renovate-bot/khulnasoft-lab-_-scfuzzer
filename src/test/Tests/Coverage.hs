module Tests.Coverage (coverageTests) where

import Test.Tasty (TestTree, testGroup)

import Common (testContract, passed, countCorpus)

coverageTests :: TestTree
coverageTests = testGroup "Coverage tests"
  [
      -- single.sol is really slow and kind of unstable. it also messes up travis.
     -- testContract "coverage/single.sol"    (Just "coverage/test.yaml")
     -- [ ("scfuzzer_state failed",                   solved      "scfuzzer_state") ]
     -- testContract' "coverage/multi.sol" Nothing Nothing (Just "coverage/test.yaml") False
     -- [ ("scfuzzer_state3 failed",                  solved      "scfuzzer_state3") ]
      testContract "coverage/boolean.sol"       (Just "coverage/boolean.yaml")
      [ ("scfuzzer_true failed",                    passed     "scfuzzer_true")
      , ("unexpected corpus count ",               countCorpus 1)]

  ]
