module Tests.Seed (seedTests) where

import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, assertBool)

import Common (runContract, overrideQuiet)
import Data.Function ((&))
import Data.IORef (readIORef)
import Scfuzzer.Output.Source (CoverageFileType(..))
import Scfuzzer.Types.Config (Env(..), EConfig(..))
import Scfuzzer.Types.Campaign
import Scfuzzer.Mutator.Corpus (defaultMutationConsts)
import Scfuzzer.Config (defaultConfig)

seedTests :: TestTree
seedTests =
  testGroup "Seed reproducibility testing"
    [ testCase "different seeds" $ assertBool "results are the same" . not =<< same 0 2
    , testCase "same seeds" $ assertBool "results differ" =<< same 0 0
    ]
    where
    cfg s = defaultConfig
      { campaignConf = CampaignConf
        { testLimit = 600
        , stopOnFail = False
        , estimateGas = False
        , seqLen = 20
        , shrinkLimit = 0
        , knownCoverage = Nothing
        , seed = Just s
        , dictFreq = 0.15
        , corpusDir = Nothing
        , mutConsts = defaultMutationConsts
        , coverageFormats = [Txt,Html,Lcov]
        , workers = Nothing
        }
      }
      & overrideQuiet
    gen s = do
      (env, _) <- runContract "basic/flags.sol" Nothing (cfg s)
      readIORef env.testsRef
    same s t = (==) <$> gen s <*> gen t
