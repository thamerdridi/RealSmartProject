# RealSmart Token — Upgradeable ERC-20 (UUPS + Pausable)

Production-ready **upgradeable ERC-20** built with **OpenZeppelin v5 (upgradeable)** and **Foundry**.

- **ERC1967 Proxy** → holds state; **implementation** → holds logic  
- **UUPS** upgrades gated by **onlyOwner**  
- **Pausable**: emergency/compliance stop for `transfer / mint / burn`


## Repo Layout

- `src/RealSmartTokenV1.sol` — ERC-20 + Pausable + UUPS (initializer mints initial supply to `OWNER`)
- `script/Deploy.s.sol` — Deploys **UUPS proxy** and calls `initialize(...)`
- `test/RealSmartTokenV1.t.sol` — Unit tests (initializer, pause/unpause, onlyOwner, re-init guard)
- `test/RealSmartTokenV2.t.sol` — (optional) example upgrade test (proxy → V2)


## Requirements

- **Foundry** (`forge`, `cast`)
- **OpenZeppelin** upgradeable libs
- A funded deployer EOA (use **Gnosis Safe** as `OWNER` in prod)

Install deps:
```bash
forge install OpenZeppelin/openzeppelin-contracts-upgradeable
forge install OpenZeppelin/openzeppelin-contracts
forge install OpenZeppelin/openzeppelin-foundry-upgrades
```

## Environment (.env)

Create a `.env` (and add it to `.gitignore`):

```bash
# generic
PRIVATE_KEY=0x...
NAME=RealSmart
SYMBOL=RSM
OWNER=0xYourSafeOrEOA
INITIAL_SUPPLY=1000000

# RPCs / scanners
AMOY_RPC=https://...
POLYGON_RPC=https://...
POLYGONSCAN_API_KEY=...
```

## Build & Test

```bash
forge build
forge test -vv
forge coverage
```

## Deploy

```bash
forge build

forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $AMOY_RPC \ or $POLYGON_RPC
  --broadcast \
  --verify \
  --ffi \
  -vvv
```
---

## Roadmap

- Identity Registry (per-address KYC flag)  
- Compliance v1 (verified-only transfers, temporary locks)  
- Minimal Roles (admin/operator)  
- Owner migration to **Gnosis Safe**
