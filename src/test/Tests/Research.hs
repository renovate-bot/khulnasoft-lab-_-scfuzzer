module Tests.Research (researchTests) where

import Test.Tasty (TestTree, testGroup)

import Common (testContract, testContract', solcV, solved)

researchTests :: TestTree
researchTests = testGroup "Research-based Integration Testing"
  [ testContract "research/harvey_foo.sol" Nothing
      [ ("scfuzzer_assert failed",     solved "scfuzzer_assert") ]
  , testContract' "research/harvey_baz.sol" Nothing Nothing Nothing False
      [ ("scfuzzer_all_states failed", solved "scfuzzer_all_states") ]
  , testContract' "research/ilf_crowdsale.sol" Nothing (Just (\v -> v >= solcV (0,5,0) && v < solcV (0,6,0))) (Just "research/ilf_crowdsale.yaml") False
      [ ("scfuzzer_assert failed", solved "withdraw") ]
  , testContract' "research/solcfuzz_funwithnumbers.sol" (Just "VerifyFunWithNumbers") (Just (< solcV (0,6,0))) (Just "research/solcfuzz_funwithnumbers.yaml") True
      [ ("scfuzzer_assert failed", solved "sellTokens"),
        ("scfuzzer_assert failed", solved "buyTokens")
      ]
  ]
