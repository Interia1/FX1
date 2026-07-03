# FX1

Modular and scalable MT5 AOS architecture scaffold.

## Structure

- `docs/ARCHITECTURE.md` - architecture blueprint and module boundaries
- `src/Experts/FX1_EA.mq5` - thin composition root (OnInit/OnTick)
- `src/Include/FX1/Core/*` - shared types, contracts, orchestrator
- `src/Include/FX1/Config/*` - settings + validation
- `src/Include/FX1/Modules/*` - unit conversion, conditions, safety, risk, execution, positions, chart, ui

## Why this layout

- strategy logic is isolated from order execution
- all symbol and unit conversions are centralized
- risk and safety are independent hard gates
- easy to add new strategies without touching engine internals

## Next implementation steps

1. Replace placeholder `CConditionModule::Evaluate` with your real signal logic.
2. Add strategy packs implementing `ICondition` and register them in `CCompositeConditionModule`.
3. Extend `CPositionModule` with break-even, trailing stop, partial exits.
4. Add session and news filters to `CSafetyModule`.
5. Add structured logging and persistent state recovery.
