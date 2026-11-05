# UsageStats (usage counts) — Specs

> **Line coverage:** `UsageStatsTestable.swift` 93% · _refreshed 2026-05-27 by `/coverage-explore`_

## Summary

Badge accessibility labels show counts ("Red badge with number 1,234"). `UsageStatsTestable` formats those
counts for display.

## Behavior & edge cases

- `formatCount` inserts thousand separators for display.

## Test scenarios

Mirrors `UsageStatsMessageTests.swift` 1:1.

- **testFormatCount_thousandSeparator** — large counts render with thousand separators.
