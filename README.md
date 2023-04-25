# Intro to testing and security of smart contracts with Foundry

## Introduction

This is a repository where you can learn the fundamental steps to use Foundry, a smart contract testing framework.

A contract to mine NFTs is used as an example, and we will see step by step how Foundry allows us to test it to find flaws and security vulnerabilities.

## Getting Started

### Requirements

- Download Foundry with the command:
`curl -L https://foundry.paradigm.xyz | bash`
- Run the `foundryup` command 
- Verify the installation of the three most important Foundry tools (`forge`, `cast` and `chisel`) by running the commands:
```
forge --version
> forge 0.2.0 

chisel --version
> chisel 0.1.1 

cast --version
> cast 0.2.0
```

## Setup

Clone this repo

```
git clone https://github.com/pinalikefruit/foundry-testing
cd foundry-testing
```
```
forge test
```