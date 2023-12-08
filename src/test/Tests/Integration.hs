module Tests.Integration (integrationTests) where

import Test.Tasty (TestTree, testGroup)

import Common (testContract, testContractV, solcV, testContract', checkConstructorConditions, passed, solved, solvedLen, solvedWith, solvedWithout, gasInRange)
import Data.Functor ((<&>))
import Data.Text (unpack)
import Scfuzzer.Types.Tx (TxCall(..))
import EVM.ABI (AbiValue(..))

integrationTests :: TestTree
integrationTests = testGroup "Solidity Integration Testing"
  [ testContract "basic/true.sol" Nothing
      [ ("scfuzzer_true failed", passed "scfuzzer_true") ]
  , testContract "basic/flags.sol" Nothing
      [ ("scfuzzer_alwaystrue failed",                      passed      "scfuzzer_alwaystrue")
      , ("scfuzzer_revert_always failed",                   passed      "scfuzzer_revert_always")
      , ("scfuzzer_sometimesfalse passed",                  solved      "scfuzzer_sometimesfalse")
      , ("scfuzzer_sometimesfalse didn't shrink optimally", solvedLen 2 "scfuzzer_sometimesfalse")
      ]
  , testContract "basic/flags.sol" (Just "basic/whitelist.yaml")
      [ ("scfuzzer_alwaystrue failed",                      passed      "scfuzzer_alwaystrue")
      , ("scfuzzer_revert_always failed",                   passed      "scfuzzer_revert_always")
      , ("scfuzzer_sometimesfalse passed",                  passed      "scfuzzer_sometimesfalse")
      ]
  , testContract "basic/flags.sol" (Just "basic/whitelist_all.yaml")
      [ ("scfuzzer_alwaystrue failed",                      passed      "scfuzzer_alwaystrue")
      , ("scfuzzer_revert_always failed",                   passed      "scfuzzer_revert_always")
      , ("scfuzzer_sometimesfalse passed",                  solved      "scfuzzer_sometimesfalse")
      ]
  , testContract "basic/flags.sol" (Just "basic/blacklist.yaml")
      [ ("scfuzzer_alwaystrue failed",                      passed      "scfuzzer_alwaystrue")
      , ("scfuzzer_revert_always failed",                   passed      "scfuzzer_revert_always")
      , ("scfuzzer_sometimesfalse passed",                  passed      "scfuzzer_sometimesfalse")
      ]
  , testContract "basic/revert.sol" Nothing
      [ ("scfuzzer_fails_on_revert passed", solved "scfuzzer_fails_on_revert")
      , ("scfuzzer_fails_on_revert didn't shrink to one transaction",
         solvedLen 1 "scfuzzer_fails_on_revert")
      , ("scfuzzer_revert_is_false didn't shrink to f(-1, 0x0, 0xdeadbeef)",
         solvedWith (SolCall ("f", [AbiInt 256 (-1), AbiAddress 0, AbiAddress 0xdeadbeef])) "scfuzzer_fails_on_revert")
      ]
  , testContract "basic/multisender.sol" (Just "basic/multisender.yaml") $
      [ ("scfuzzer_all_sender passed",                      solved             "scfuzzer_all_sender")
      , ("scfuzzer_all_sender didn't shrink optimally",     solvedLen 3        "scfuzzer_all_sender")
      ] ++ (["s1", "s2", "s3"] <&> \n ->
        ("scfuzzer_all_sender solved without " ++ unpack n, solvedWith (SolCall (n, [])) "scfuzzer_all_sender"))
  , testContract "basic/memory-reset.sol" Nothing
      [ ("scfuzzer_memory failed",                  passed      "scfuzzer_memory") ]
  , testContract "basic/contractAddr.sol" (Just "basic/contractAddr.yaml")
      [ ("scfuzzer_address failed",                 passed      "scfuzzer_address") ]
  , testContractV "basic/balance.sol"     (Just (< solcV (0,8,0)))  (Just "basic/balance.yaml")
      [ ("scfuzzer_balance failed",                 passed      "scfuzzer_balance")
      , ("scfuzzer_balance_new failed",             passed      "scfuzzer_balance_new")
      , ("scfuzzer_low_level_call failed",          passed      "scfuzzer_low_level_call")
      , ("scfuzzer_no_magic failed",                passed      "scfuzzer_no_magic")
      ]
  , testContract "basic/library.sol"      (Just "basic/library.yaml")
      [ ("scfuzzer_library_call failed",            solved      "scfuzzer_library_call")
      , ("scfuzzer_valid_timestamp failed",         passed      "scfuzzer_valid_timestamp")
      ]
  , testContractV "basic/fallback.sol"   (Just (< solcV (0,6,0))) Nothing
      [ ("scfuzzer_fallback failed",                solved      "scfuzzer_fallback") ]
  , testContract "basic/push_long.sol" (Just "basic/push_long.yaml")
      [ ("test_long_5 passed",                     solvedWithout NoCall "test_long_5")]
  , testContract "basic/propGasLimit.sol" (Just "basic/propGasLimit.yaml")
      [ ("scfuzzer_runForever passed",              solved      "scfuzzer_runForever") ]
  , testContract "basic/delay.sol"        Nothing
      [ ("scfuzzer_block_number passed",            solved    "scfuzzer_block_number")
      , ("scfuzzer_timestamp passed",               solved    "scfuzzer_timestamp") ]
  , testContractV "basic/immutable.sol"    (Just (>= solcV (0,6,0))) Nothing
      [ ("scfuzzer_test passed",                    solved      "scfuzzer_test") ]
  , testContract "basic/construct.sol"    Nothing
      [ ("scfuzzer_construct passed",               solved      "scfuzzer_construct") ]
  , testContract "basic/gasprice.sol"     (Just "basic/gasprice.yaml")
      [ ("scfuzzer_state passed",                   solved      "scfuzzer_state") ]
  , testContract' "basic/allContracts.sol" (Just "B") Nothing (Just "basic/allContracts.yaml") True
      [ ("scfuzzer_test passed",                    solved      "scfuzzer_test") ]
  , testContract "basic/array-mutation.sol"   Nothing
      [ ("scfuzzer_mutated passed",                 solved      "scfuzzer_mutated") ]
  , testContract "basic/darray-mutation.sol"  Nothing
      [ ("scfuzzer_mutated passed",                 solved      "scfuzzer_mutated") ]
  , testContract "basic/gasuse.sol"       (Just "basic/gasuse.yaml")
      [ ("scfuzzer_true failed",                    passed     "scfuzzer_true")
      , ("g gas estimate wrong",                   gasInRange "g" 130000 40000000)
      , ("f_close1 gas estimate wrong",            gasInRange "f_close1" 400 2000)
      , ("f_open1 gas estimate wrong",             gasInRange "f_open1"  18000 23000)
      , ("push_b gas estimate wrong",              gasInRange "push_b"   39000 45000)
      ]
  , testContract "basic/gaslimit.sol"  Nothing
      [ ("scfuzzer_gaslimit passed",                passed      "scfuzzer_gaslimit") ]
  ,  testContractV "basic/killed.sol"      (Just (< solcV (0,8,0))) Nothing
      [ ("scfuzzer_still_alive failed",             solved      "scfuzzer_still_alive") ]
  ,  checkConstructorConditions "basic/codesize.sol"
      "invalid codesize"
  , testContractV "basic/eip-170.sol" (Just (>= solcV (0,5,0))) (Just "basic/eip-170.yaml")
      [ ("scfuzzer_test passed",                    passed      "scfuzzer_test") ]
  , testContract' "basic/deploy.sol" (Just "Test") Nothing (Just "basic/deployContract.yaml") True
      [ ("test passed",                    solved     "test") ]
  , testContract' "basic/deploy.sol" (Just "Test") Nothing (Just "basic/deployBytecode.yaml") True
      [ ("test passed",                    solved     "test") ]
  , testContract "basic/flags.sol" (Just "basic/etheno-query-error.yaml")
      [] -- Just check if the etheno config does not crash Scfuzzer
  ]
