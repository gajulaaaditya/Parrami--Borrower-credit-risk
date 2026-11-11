# Verification record

## Executed successfully

- Generated 240 borrower, 300 loan and 3,600 monthly rows using the Python standard library.
- Loaded all three CSVs and executed the exact shared SQL scripts 01–03 in SQLite.
- Exported eleven report tables to CSV and copied those to expected_results.
- All nine mandatory quality checks returned zero failures.
- Confirmed 290 unique active loan rows, nine historical monthly rows and exclusion of future snapshots/zero balances.
- Reconciled product, region and risk exposure totals to the portfolio total.
- Checked missingness counts, borrower-level multi-loan DTI, and the exact 0/29/30/59/60/90-day DPD bucket boundaries.
- Checked loss/probability bounds and hand-calculated count-vs-balance delinquency and loss examples.
- Injected a duplicate snapshot and verified that the quality query detected it.
- Executed every optional practice solution query in SQLite.
- Built the single-file SAS route from canonical files and checked its embedded record counts and inclusion of each shared SQL script.
- Checked ZIP integrity and manifest checksums.

Run `python3 tools/verify.py` to repeat the core checks. Run `python3 tools/run_local.py` to regenerate outputs. Assertions are intended to run normally; do not use Python's `-O` switch, which disables assert statements.

## Not executed here

No SAS runtime was available. Neither SAS entry point was executed in SAS OnDemand/SAS Studio. The SAS code uses explicit input schemas and conventional PROC SQL constructs, but SAS runtime compatibility remains to be confirmed by running the provided file in your SAS account. The SQLite run does not establish identical SAS semantics. Inspect the SAS log and compare exported numeric results with expected_results using README tolerances.

The 2025 snapshots, score associations, PD assumptions and collateral rules are synthetic teaching inputs. The project has no predictive-validation or business-impact claim.
