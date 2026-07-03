# FX1 MT5 AOS Architecture

This repository contains a modular Expert Advisor architecture for MT5.

Design goals:
- simple module boundaries
- deterministic data flow
- clear separation: signal, risk, execution
- symbol-agnostic handling of points, pips, spread, slippage, volume
- easy scaling from one strategy to many strategy packs

## Runtime Flow

1. EA bootstraps modules in `OnInit`.
2. `CEngine::OnTick` creates one `SMarketSnapshot`.
3. Safety gate decides if trading is allowed.
4. Condition module (or composite condition module) emits `SSignal`.
5. Risk module transforms signal into `SRiskDecision`.
6. Execution module sends/modifies orders.
7. Position manager handles open trades (BE, trailing, partials).
8. Chart and UI modules render diagnostics and controls.

## Module Set

- Core
  - `Types.mqh`: shared data models
  - `Contracts.mqh`: module interfaces
  - `AppContext.mqh`: immutable runtime context + validated settings
  - `Engine.mqh`: orchestrator only
- Config
  - `Settings.mqh`: inputs and validation
- Modules
  - `UnitConversion.mqh`: points/price/volume/spread/slippage normalization
  - `ConditionModule.mqh`: primitive strategy conditions
  - `CompositeConditionModule.mqh`: composed conditions (AND baseline)
  - `SafetyModule.mqh`: hard guards (spread/session/trade frequency)
  - `RiskModule.mqh`: sizing and stop/target rules
  - `ExecutionModule.mqh`: order send + trade API adapter
  - `PositionModule.mqh`: lifecycle of open positions
  - `ChartModule.mqh`: chart diagnostics
  - `UiModule.mqh`: on-chart controls and runtime toggles
- Expert
  - `FX1_EA.mq5`: thin composition root

## Scalability Rules

- Keep strategy logic in `ConditionModule` and `CompositeConditionModule` only.
- Keep broker/symbol specifics in `UnitConversion` only.
- Keep risk math in `RiskModule` only.
- Keep order sending in `ExecutionModule` only.
- `Engine` must never contain strategy-specific code.

## Extension Pattern

To add a new strategy pack:
1. Create a new condition class implementing `ICondition`.
2. Register it in `CompositeConditionModule`.
3. Reuse existing safety/risk/execution modules.

## Non-Goals

- no monolithic god-class EA
- no hidden conversions in random modules
- no direct order operations from conditions
