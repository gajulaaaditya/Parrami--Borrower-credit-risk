# Borrower Credit Risk Analysis — SQL / SAS PROC SQL

**Independent portfolio practice project inspired by Parrami Finance.** All people, loans, balances, rules and outcomes are synthetic. This is not work performed at Parrami Finance, is not affiliated with that company, and describes no actual company systems, policies, customers or internship duties.

## What you will build

A lending portfolio analysis as of **30 September 2025**: clean and join three tables, calculate borrower affordability, segment active loans, summarize financial exposure and delinquency, and prioritize a collections queue. Amounts are simulated INR; rates are decimal fractions (0.12 = 12%). These choices describe this simulation only.

Included: 240 borrowers, 300 loans and 3,600 month-end observations for January–December 2025. Ten loans have zero balance at the reporting date; the analysis has 290 active loans and 234 active borrowers. Missing income and scores are intentional. Future observations test reporting-date discipline.

## Fastest SAS start: one file

Upload or open `sas/standalone_project.sas` in SAS Studio and submit the entire file. It embeds all synthetic records and the same analysis; no root-path edit or CSV upload is needed. Inspect the printed summary and WORK tables. This route keeps reports in WORK rather than exporting CSVs. Use the folder-based route below for automatic CSV exports. `python3 tools/build_standalone.py` rebuilds this file after changing the canonical CSV/SQL source files.

## Run in SAS OnDemand / SAS Studio (folder-based exports)

1. Download and extract the ZIP on your computer. Sign into your SAS OnDemand for Academics account and open SAS Studio.
2. In the server files pane (wording varies by version), create a folder `borrower-credit-risk` in your writable server home. Create subfolders `data`, `sql`, `sas` and `results`.
3. Upload the three CSVs into `data`, the three numbered SQL files into `sql`, and the three SAS files into `sas`. Python, documentation and reference results do not need uploading. Upload `practice_solutions.sql` only if you want to run the exercises.
4. Open `sas/run_project.sas`. Set `%let root=` to the **server's full folder path**, for example `/home/u12345678/borrower-credit-risk`. Use the path shown by your server, without a trailing slash. A local Downloads path will not work on the SAS server.
5. Submit the entire program. Read the Log for ERROR messages and unexpected warnings. `WORK.QA_FAILURES` must contain nine rows with zero `failure_count`. `WORK.DATA_QUALITY_PROFILE` should show six missing incomes and five missing scores.
6. Inspect the Results tab and WORK tables. Eleven report CSVs appear in the server's `results` folder. Download them to retain results after your session ends. Tables in WORK are temporary.
7. Compare the portfolio summary with `expected_results/portfolio_summary.csv`. Floating-point precision, column order and row ordering can differ. Compare ratios within 1e-8 and amounts within INR 0.01.

The SAS entry point imports explicit types with DATA steps, then runs all analysis in PROC SQL using the same SQL files as the local route. DATA steps and PROC EXPORT are used for file input/output, not the analytical calculations. No database connection, Python or SAS add-on is required for the SAS route. Rerunning replaces the project's WORK tables and report files.

## Run locally with Python 3 (optional)

From a terminal inside the extracted `borrower-credit-risk` folder:

```sh
python3 tools/run_local.py
python3 tools/verify.py
```

On Windows, use `py` if `python3` is unavailable. Only the Python standard library is needed; SQLite is included with normal Python distributions. The runner loads CSVs into an in-memory database, executes the same three SQL scripts, and exports reports to `results/`. It does not execute SAS wrappers.

Optional: `python3 tools/generate_data.py` recreates the bundled inputs using seed 20261110 and overwrites `data/*.csv`. The supplied CSVs are the definitive reference inputs; random-library behavior may vary across Python versions. No regeneration is necessary.

## Files and run order

| File | Purpose |
|---|---|
| `data/*.csv` | Ready-to-use synthetic source tables |
| `sas/standalone_project.sas` | Single-file SAS route with embedded data |
| `sas/run_project.sas` | SAS entry point; edit the root path here |
| `sas/01_import.sas` | Explicit CSV schemas and missing-value handling |
| `sql/01_quality.sql` | Mandatory integrity checks and missingness profile |
| `sql/02_features.sql` | Reporting-date loans, borrower DTI, risk and loss assumptions |
| `sql/03_reports.sql` | Portfolio, segment, product, region, trend and collections reports |
| `sas/03_export.sas` | CSV exports and printed summary |
| `sql/practice_solutions.sql` | Optional runnable query answers after the main analysis |
| `docs/DATA_DICTIONARY.md` | Grain, keys and every source field |
| `docs/METRICS_AND_RULES.md` | Financial definitions, formulas and limitations |
| `docs/PRACTICE_QUESTIONS.md` | SQL and interview exercises |
| `docs/ANSWER_GUIDE.md` | Answer explanations and honest interview wording |
| `docs/FINDINGS.md` | Reference findings and suggested analysis |
| `docs/VERIFICATION.md` | Executed checks and SAS verification limits |
| `expected_results/*.csv` | Reference outputs generated locally from bundled data |

## Important design decisions

- Join performance to loans on loan ID **and the reporting date** before summarizing exposure. Joining all 12 months would multiply balances and loan counts.
- Add all active project-loan installments per borrower before computing DTI. Existing debt is defined to exclude these project loans, preventing double counting.
- Income and score missingness remain missing. An `Unclassified` segment routes incomplete records for review; it is not a low-risk category.
- Dates are ISO `YYYY-MM-DD` character fields. Their fixed-width, zero-padded form permits lexical comparisons in both engines. Do not use SAS date arithmetic on them directly; convert using `input(date,yymmdd10.)` if extending the project.
- SQL uses CASE, joins and grouped summary tables. It avoids window functions, CTEs, LIMIT and database-specific date functions. SAS runs with `NOREMERGE` to catch accidental detail/aggregate mixing.
- The nine quality checks cover this supplied schema, not every possible malformed external file. Validate ISO date syntax, ranges and required categorical values before adapting this importer to outside data.

## Troubleshooting

- **File does not exist:** verify the server root and exact subfolder/file names; upload all required files.
- **Cannot export:** create the `results` folder and check it is writable.
- **QA gate stops:** inspect nonzero rows in `WORK.QA_FAILURES`; restore the supplied inputs or fix the source issue before continuing.
- **Character values cut off:** keep supplied SAS lengths when importing. Avoid PROC IMPORT guesses when recreating the inputs.
- **SQL error:** open the first error in the Log, correct it and rerun the entire entry point. Downstream tables may be stale from an earlier successful run.
- **Percentages look small:** reports store fractions. Multiply by 100 for display only, or apply a SAS `percent8.2` format to a display copy.

## Verification status

The generator, complete shared SQL pipeline, CSV exports and outcome checks were executed locally using Python/SQLite. SAS scripts were prepared for SAS PROC SQL/SAS OnDemand but were **not executed in a SAS runtime** here. `expected_results` are SQLite reference outputs, not purported SAS results. Follow the SAS steps above to complete runtime verification in your account.

## Technical references

- [SAS: SQL SELECT statement](https://support.sas.com/documentation/cdl/en/proc/61895/HTML/default/a002473678.htm) — PROC SQL query and grouping behavior.
- [SAS: Summary functions](https://support.sas.com/documentation/cdl/en/proc/61895/HTML/default/a002473699.htm) — column aggregates, row functions and remerging.
- [SAS: Reading raw data](https://support.sas.com/documentation/cdl/en/lrcon/62955/HTML/default/a003209907.htm) — delimiter-separated input and DSD missing fields.

The references support SAS syntax. All credit rules and financial assumptions in this project are invented teaching choices.
