# Scfuzzer: A Fast Smart Contract Fuzzer

![Build Status](https://github.com/khulnasoft-lab/scfuzzer/workflows/CI/badge.svg)

Scfuzzer is a weird creature that eats bugs and is highly electrosensitive (with apologies to Jacob Stanley)

More seriously, Scfuzzer is a Haskell program designed for fuzzing/property-based testing of Ethereum smart contracts. It uses sophisticated grammar-based fuzzing campaigns based on a [contract ABI](https://solidity.readthedocs.io/en/develop/abi-spec.html) to falsify user-defined predicates or [Solidity assertions](https://solidity.readthedocs.io/en/develop/control-structures.html#id4). We designed Scfuzzer with modularity in mind, so it can be easily extended to include new mutations or test specific contracts in specific cases.

## Features

* Generates inputs tailored to your actual code
* Optional corpus collection, mutation and coverage guidance to find deeper bugs
* Powered by [Slither](https://github.com/khulnasoft-lab/slither) to extract useful information before the fuzzing campaign
* Source code integration to identify which lines are covered after the fuzzing campaign
* Interactive terminal UI, text-only or JSON output
* Automatic test case minimization for quick triage
* Seamless integration into the development workflow
* Maximum gas usage reporting of the fuzzing campaign
* Support for a complex contract initialization with [Etheno](https://github.com/khulnasoft-lab/etheno) and Truffle

.. and [a beautiful high-resolution handcrafted logo](https://raw.githubusercontent.com/khulnasoft-lab/scfuzzer/master/scfuzzer.png).

<a href="https://i.imgur.com/saFWti4.png"><img src="https://i.imgur.com/saFWti4.png" width="650"/></a>

## Usage

### Executing the test runner

The core Scfuzzer functionality is an executable called `scfuzzer`, which takes a contract and a list
of invariants (properties that should always remain true) as input. For each invariant, it generates
random sequences of calls to the contract and checks if the invariant holds. If it can find some way
to falsify the invariant, it prints the call sequence that does so. If it can't, you have some
assurance the contract is safe.

### Writing invariants

Invariants are expressed as Solidity functions with names that begin with `scfuzzer_`, have no arguments, and return a boolean. For example, if you have some `balance` variable that should never go below `20`, you can write an extra function in your contract like this one:

```solidity
function scfuzzer_check_balance() public returns (bool) {
    return(balance >= 20);
}
```

To check these invariants, run:

```sh
$ scfuzzer myContract.sol
```

An example contract with tests can be found [tests/solidity/basic/flags.sol](tests/solidity/basic/flags.sol). To run it, you should execute:

```sh
$ scfuzzer tests/solidity/basic/flags.sol
```

Scfuzzer should find a call sequence that falsifies `scfuzzer_sometimesfalse` and should be unable to find a falsifying input for `scfuzzer_alwaystrue`.

### Collecting and visualizing coverage

After finishing a campaign, Scfuzzer can save a coverage maximizing **corpus** in a special directory specified with the `corpusDir` config option. This directory will contain two entries: (1) a directory named `coverage` with JSON files that can be replayed by Scfuzzer and (2) a plain-text file named `covered.txt`, a copy of the source code with coverage annotations.

If you run `tests/solidity/basic/flags.sol` example, Scfuzzer will save a few files serialized transactions in the `coverage` directory and a `covered.$(date +%s).txt` file with the following lines:

```text
*r  |  function set0(int val) public returns (bool){
*   |    if (val % 100 == 0)
*   |      flag0 = false;
  }

*r  |  function set1(int val) public returns (bool){
*   |    if (val % 10 == 0 && !flag0)
*   |      flag1 = false;
  }
```

Our tool signals each execution trace in the corpus with the following "line marker":

* `*` if an execution ended with a STOP
* `r` if an execution ended with a REVERT
* `o` if an execution ended with an out-of-gas error
* `e` if an execution ended with any other error (zero division, assertion failure, etc)

### Support for smart contract build systems

Scfuzzer can test contracts compiled with different smart contract build systems, including [Truffle](https://truffleframework.com/) or [hardhat](https://hardhat.org/) using [khulnasoft-compile](https://github.com/khulnasoft-lab/khulnasoft-compile). To invoke scfuzzer with the current compilation framework, use `scfuzzer .`.

On top of that, Scfuzzer supports two modes of testing complex contracts. Firstly, one can [describe an initialization procedure with Truffle and Etheno](https://github.com/khulnasoft-lab/building-secure-contracts/blob/master/program-analysis/scfuzzer/end-to-end-testing.md) and use that as the base state for Scfuzzer. Secondly, Scfuzzer can call into any contract with a known ABI by passing in the corresponding Solidity source in the CLI. Use `allContracts: true` in your config to turn this on.

### Crash course on Scfuzzer

Our [Building Secure Smart Contracts](https://github.com/khulnasoft-lab/building-secure-contracts/tree/master/program-analysis/scfuzzer#scfuzzer-tutorial) repository contains a crash course on Scfuzzer, including examples, lessons and exercises.

### Using Scfuzzer in a GitHub Actions workflow

There is an Scfuzzer action which can be used to run `scfuzzer` as part of a
GitHub Actions workflow. Please refer to the
[khulnasoft-lab/scfuzzer-action](https://github.com/khulnasoft-lab/scfuzzer-action) repository for
usage instructions and examples.

### Configuration options

Scfuzzer's CLI can be used to choose the contract to test and load a
configuration file.

```sh
$ scfuzzer contract.sol --contract TEST --config config.yaml
```

The configuration file allows users to choose EVM and test generation
parameters. An example of a complete and annotated config file with the default
options can be found at
[tests/solidity/basic/default.yaml](tests/solidity/basic/default.yaml).
More detailed documentation on the configuration options is available in our
[wiki](https://github.com/trailofbits/scfuzzer/wiki/Config).

Scfuzzer supports three different output drivers. There is the default `text`
driver, a `json` driver, and a `none` driver, which should suppress all
`stdout` output. The JSON driver reports the overall campaign as follows.

```
Campaign = {
  "success"      : bool,
  "error"        : string?,
  "tests"        : [Test],
  "seed"         : number,
  "coverage"     : Coverage,
  "gas_info"     : [GasInfo]
}
Test = {
  "contract"     : string,
  "name"         : string,
  "status"       : string,
  "error"        : string?,
  "testType"     : string,
  "transactions" : [Transaction]?
}
Transaction = {
  "contract"     : string,
  "function"     : string,
  "arguments"    : [string]?,
  "gas"          : number,
  "gasprice"     : number
}
```

`Coverage` is a dict describing certain coverage-increasing calls.
Each `GasInfo` entry is a tuple that describes how maximal
gas usage was achieved, and is also not too important. These interfaces are
subject to change to be slightly more user-friendly at a later date. `testType`
will either be `property` or `assertion`, and `status` always takes on either
`fuzzing`, `shrinking`, `solved`, `passed`, or `error`.

### Debugging Performance Problems

One way to diagnose Scfuzzer's performance issues is to run `scfuzzer` with profiling on.
To run Scfuzzer with basic profiling, add `+RTS -p -s` to your original `scfuzzer` command:

```sh
$ nix develop # alternatively nix-shell
$ cabal --enable-profiling run scfuzzer -- ... +RTS -p -s
$ less scfuzzer.prof
```

This produces a report file (`scfuzzer.prof`), that shows which functions take up the most CPU and memory usage.

If the basic profiling doesn't help, you can use more [advanced profiling techniques](https://input-output-hk.github.io/hs-opt-handbook.github.io/src/Measurement_Observation/Heap_Ghc/eventlog.html).

Common causes for performance issues that we observed:

- Costly functions called in hot paths
- Lazy data constructors that accumulate thunks
- Inefficient data structures used in hot paths

Checking for these is a good place to start. If you suspect some comuptation is too lazy and
leaks memory, you can use `force` from `Control.DeepSeq` to make sure it gets evaluated.

## Limitations and known issues

EVM emulation and testing are hard. Scfuzzer has some limitations in the latest release. Some of
these are inherited from [hevm](https://github.com/ethereum/hevm) while some are results from
design/performance decisions or simply bugs in our code. We list them here including their
corresponding issue and the status ("wont fix", "on hold", "in review", "fixed"). Issues that are
"fixed" are expected to be included in the next Scfuzzer release.

| Description | Issue | Status |
| :---        | :---: | :---:  |
| Vyper support is limited | [#652](https://github.com/khulnasoft-lab/scfuzzer/issues/652) | *wont fix* |
| Limited library support for testing | [#651](https://github.com/khulnasoft-lab/scfuzzer/issues/651) | *wont fix* |

## Installation

### Precompiled binaries

Before starting, make sure Slither is [installed](https://github.com/khulnasoft-lab/slither) (`pip3 install slither-analyzer --user`).
If you want to quickly test Scfuzzer in Linux or MacOS, we provide statically linked Linux binaries built on Ubuntu and mostly static MacOS binaries on our [releases page](https://github.com/khulnasoft-lab/scfuzzer/releases). You can also grab the same type of binaries from our [CI pipeline](https://github.com/khulnasoft-lab/scfuzzer/actions?query=workflow%3ACI+branch%3Amaster+event%3Apush), just click the commit to find binaries for Linux or MacOS.

### Homebrew (macOS / Linux)

If you have Homebrew installed on your Mac or Linux machine, you can install Scfuzzer and all of its dependencies (Slither, khulnasoft-compile) by running `brew install scfuzzer`.

You can also compile and install the latest `master` branch code by running `brew install --HEAD scfuzzer`

You can get further information in the [`scfuzzer` Homebrew Formula](https://formulae.brew.sh/formula/scfuzzer) page. The formula itself is maintained as part of the [homebrew-core repository](https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/e/scfuzzer.rb)

### Docker container

If you prefer to use a pre-built Docker container, check out our [docker
package](https://github.com/orgs/khulnasoft-lab/packages?repo_name=scfuzzer), which is
auto-built via GitHub Actions. The `scfuzzer` container is based on
`ubuntu:focal` and it is meant to be a small yet flexible enough image to use
Scfuzzer on. It provides a pre-built version of `scfuzzer`, as well as
`slither`, `khulnasoft-compile`, `solc-select` and `nvm` under 200 MB.

Note that the container images currently only build on x86 systems. Running them
on ARM devices, such as Mac M1 systems, is not recommended due to the performance
loss incurred by the CPU emulation.

Different tags are available for the Docker container image:

| Tag           | Build in tag
|---------------|-------------
| `vx.y.z`      | Build corresponding to release `vx.y.z`
| `latest`      | Latest Scfuzzer tagged release.
| `edge`        | Most recent commit on the default branch.
| `testing-foo` | Testing build based on the `foo` branch.

To run the container with the latest Scfuzzer version interactively, you can use
something like the following command. It will map the current directory as
`/src` inside the container, and give you a shell where you can use
`scfuzzer`:

```sh
$ docker run --rm -it -v `pwd`:/src ghcr.io/khulnasoft-lab/scfuzzer/scfuzzer
```

Otherwise, if you want to locally build the latest version of Scfuzzer, we
recommend using Docker. From within a clone of this repository, run the
following command to build the Docker container image:

```sh
$ docker build -t scfuzzer -f docker/Dockerfile --target final-ubuntu .
```

Then, you can run the `scfuzzer` image locally. For example, to install solc
0.5.7 and check `tests/solidity/basic/flags.sol`, you can run:

```sh
$ docker run -it -v `pwd`:/src scfuzzer bash -c "solc-select install 0.5.7 && solc-select use 0.5.7 && scfuzzer /src/tests/solidity/basic/flags.sol"
```

### Building using Stack

If you'd prefer to build from source, use [Stack](https://docs.haskellstack.org/en/stable/README/). `stack install` should build and compile `scfuzzer` in `~/.local/bin`. You will need to link against libreadline and libsecp256k1 (built with recovery enabled), which should be installed with the package manager of your choosing. You also need to install the latest release of [libff](https://github.com/scipr-lab/libff). Refer to our [CI tests](.github/scripts/install-libff.sh) for guidance.

Some Linux distributions do not ship static libraries for certain things that Haskell needs, e.g. Arch Linux, which will cause `stack build` to fail with linking errors because we use the `-static` flag. In that case, use `--flag scfuzzer:-static` to produce a dynamically linked binary.

If you're getting errors building related to linking, try tinkering with `--extra-include-dirs` and `--extra-lib-dirs`.

### Building using Nix (works natively on Apple M1 systems)

[Nix users](https://nixos.org/download.html) can install the latest Scfuzzer with:

```sh
$ nix-env -i -f https://github.com/khulnasoft-lab/scfuzzer/tarball/master
```

With flakes enabled, you can run Scfuzzer straight from this repo:
```sh
$ nix run github:khulnasoft-lab/scfuzzer # master
$ nix run github:khulnasoft-lab/scfuzzer/v2.1.1 # specific ref (tag/branch/commit)
```

To build a standalone release for non-Nix macOS systems, the following will
build Scfuzzer in a mostly static binary. This can also be used on Linux systems
to produce a fully static binary.

```sh
$ nix build .#scfuzzer-redistributable
```

Nix will automatically install all the dependencies required for development
including `khulnasoft-compile` and `solc`. A quick way to start developing Scfuzzer:

```sh
$ git clone https://github.com/khulnasoft-lab/scfuzzer
$ cd scfuzzer
$ nix develop # alternatively nix-shell
[nix-shell]$ cabal run scfuzzer
[nix-shell]$ cabal run tests
[nix-shell]$ cabal new-repl
```

## Public use of Scfuzzer

### Property testing suites

This is a partial list of smart contracts projects that use Scfuzzer for testing:

* [Primitive](https://github.com/primitivefinance/rmm-core/tree/main/contracts/khulnasoft)
* [Uniswap-v3](https://github.com/search?q=org%3AUniswap+scfuzzer&type=commits)
* [Balancer](https://github.com/balancer-labs/balancer-core/tree/master/scfuzzer)
* [MakerDAO vest](https://github.com/makerdao/dss-vest/pull/16)
* [Optimism DAI Bridge](https://github.com/BellwoodStudios/optimism-dai-bridge/blob/master/contracts/test/DaiScfuzzerTest.sol)
* [WETH10](https://github.com/WETH10/WETH10/tree/main/contracts/fuzzing)
* [Yield](https://github.com/yieldprotocol/fyDai/pull/312)
* [Convexity Protocol](https://github.com/opynfinance/ConvexityProtocol/tree/dev/contracts/scfuzzer)
* [Aragon Staking](https://github.com/aragon/staking/blob/82bf54a3e11ec4e50d470d66048a2dd3154f940b/packages/protocol/contracts/test/lib/ScfuzzerStaking.sol)
* [Centre Token](https://github.com/centrehq/centre-tokens/tree/master/scfuzzer_tests)
* [Tokencard](https://github.com/tokencard/contracts/tree/master/tools/scfuzzer)
* [Minimalist USD Stablecoin](https://github.com/usmfum/USM/pull/41)

### Trophies

The following security vulnerabilities were found by Scfuzzer. If you found a security vulnerability using our tool, please submit a PR with the relevant information.

| Project | Vulnerability | Date |
|--|--|--|
[0x Protocol](https://github.com/trailofbits/publications/blob/master/reviews/0x-protocol.pdf) | If an order cannot be filled, then it cannot be canceled | Oct 2019
[0x Protocol](https://github.com/trailofbits/publications/blob/master/reviews/0x-protocol.pdf) | If an order can be partially filled with zero, then it can be partially filled with one token | Oct 2019
[0x Protocol](https://github.com/trailofbits/publications/blob/master/reviews/0x-protocol.pdf) | The cobbdouglas function does not revert when valid input parameters are used | Oct 2019
[Balancer Core](https://github.com/trailofbits/publications/blob/master/reviews/BalancerCore.pdf) | An attacker cannot steal assets from a public pool | Jan 2020
[Balancer Core](https://github.com/trailofbits/publications/blob/master/reviews/BalancerCore.pdf) | An attacker cannot generate free pool tokens with joinPool | Jan 2020
[Balancer Core](https://github.com/trailofbits/publications/blob/master/reviews/BalancerCore.pdf) | Calling joinPool-exitPool does not lead to free pool tokens | Jan 2020
[Balancer Core](https://github.com/trailofbits/publications/blob/master/reviews/BalancerCore.pdf) |  Calling exitswapExternAmountOut does not lead to free assets | Jan 2020
[Liquity Dollar](https://github.com/trailofbits/publications/blob/master/reviews/Liquity.pdf) | [Closing troves require to hold the full amount of LUSD minted](https://github.com/liquity/dev/blob/scfuzzer_ToB_final/packages/contracts/contracts/TestContracts/E2E.sol#L242-L298) | Dec 2020
[Liquity Dollar](https://github.com/trailofbits/publications/blob/master/reviews/Liquity.pdf) | [Troves can be improperly removed](https://github.com/liquity/dev/blob/scfuzzer_ToB_final/packages/contracts/contracts/TestContracts/E2E.sol#L242-L298) | Dec 2020
[Liquity Dollar](https://github.com/trailofbits/publications/blob/master/reviews/Liquity.pdf) | Initial redeem can revert unexpectedly | Dec 2020
[Liquity Dollar](https://github.com/trailofbits/publications/blob/master/reviews/Liquity.pdf) | Redeem without redemptions might still return success | Dec 2020
[Origin Dollar](https://github.com/trailofbits/publications/blob/master/reviews/OriginDollar.pdf) | Users are allowed to transfer more tokens that they have | Nov 2020
[Origin Dollar](https://github.com/trailofbits/publications/blob/master/reviews/OriginDollar.pdf) | User balances can be larger than total supply | Nov 2020
[Yield Protocol](https://github.com/trailofbits/publications/blob/master/reviews/YieldProtocol.pdf) | Arithmetic computation for buying and selling tokens is imprecise | Aug 2020

### Research

We can also use Scfuzzer to reproduce research examples from smart contract fuzzing papers to show how quickly it can find the solution. All of these can be solved, in a few seconds to one or two minutes on a laptop computer.

| Source | Code
|--|--
[Using automatic analysis tools with MakerDAO contracts](https://forum.openzeppelin.com/t/using-automatic-analysis-tools-with-makerdao-contracts/1021) | [SimpleDSChief](https://github.com/khulnasoft-lab/scfuzzer/blob/master/tests/solidity/research/vera_dschief.sol)
[Integer precision bug in Sigma Prime](https://github.com/b-mueller/sabre#example-2-integer-precision-bug) | [VerifyFunWithNumbers](https://github.com/khulnasoft-lab/scfuzzer/blob/master/tests/solidity/research/solcfuzz_funwithnumbers.sol)
[Learning to Fuzz from Symbolic Execution with Application to Smart Contracts](https://files.sri.inf.ethz.ch/website/papers/ccs19-ilf.pdf) | [Crowdsale](https://github.com/khulnasoft-lab/scfuzzer/blob/master/tests/solidity/research/ilf_crowdsale.sol)
[Harvey: A Greybox Fuzzer for Smart Contracts](https://arxiv.org/abs/1905.06944) | [Foo](https://github.com/khulnasoft-lab/scfuzzer/blob/master/test/solidity/research/harvey_foo.sol), [Baz](https://github.com/khulnasoft-lab/scfuzzer/blob/master/tests/solidity/research/harvey_baz.sol)

### Academic Publications

| Paper Title | Venue | Publication Date |
| --- | --- | --- |
| [scfuzzer-parade: Diverse multicore smart contract fuzzing](https://agroce.github.io/issta21.pdf) | [ISSTA 2021](https://conf.researchr.org/home/issta-2021) | July 2021 |
| [Scfuzzer: Effective, usable, and fast fuzzing for smart contracts](https://agroce.github.io/issta20.pdf) | [ISSTA 2020](https://conf.researchr.org/home/issta-2020) | July 2020 |
| [Scfuzzer: A Practical Smart Contract Fuzzer](papers/scfuzzer_fc_poster.pdf) | [FC 2020](https://fc20.ifca.ai/program.html) | Feb 2020 |

If you are using Scfuzzer for academic work, consider applying to the [Crytic $10k Research Prize](https://blog.trailofbits.com/2019/11/13/announcing-the-khulnasoft-10k-research-prize/).

## Getting help

Feel free to stop by our #ethereum slack channel in [Empire Hacking](https://slack.empirehacking.nyc/) for help using or extending Scfuzzer.

* Get started by reviewing these simple [Scfuzzer invariants](tests/solidity/basic/flags.sol)

* Considering [emailing](mailto:scfuzzer-dev@trailofbits.com) the Scfuzzer development team directly for more detailed questions

## License

Scfuzzer is licensed and distributed under the [AGPLv3 license](https://github.com/khulnasoft-lab/scfuzzer/blob/master/LICENSE).
