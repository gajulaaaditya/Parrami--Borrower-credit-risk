# Findings from the synthetic reference run

These are simulated results, not company observations. Reporting date: 30 September 2025. Currency: simulated INR. Reference calculations were run using the shared SQL in SQLite.

| Metric | Result |
|---|---:|
| Active borrowers | 234 |
| Active loans | 290 |
| Principal exposure | INR 7,021,344.00 |
| Loan count 30+ DPD rate | 59.31% |
| PAR30 | 62.61% |
| Loan count 90+ DPD rate | 15.86% |
| PAR90 | 16.01% |
| Balance-weighted contractual annual rate | 15.75% |
| Static annual interest run rate | INR 1,106,191.08 |
| Illustrative expected loss | INR 782,123.00 |
| Illustrative loss / exposure | 11.14% |
| Borrower mean DTI among 228 known DTIs | 38.84% |
| Known-DTI borrowers above 50% | 22.81% |

## Segment distribution

| Segment | Loans | Exposure (INR) | Illustrative loss (INR) |
|---|---:|---:|---:|
| High | 185 | 4,826,076 | 691,475.84 |
| Medium | 56 | 1,259,040 | 30,936.80 |
| Low | 36 | 632,448 | 3,836.28 |
| Unclassified | 13 | 303,780 | 55,874.08 |

PAR30 exceeds the count-based delinquency rate, indicating that overdue loans carry more than their proportional share of exposure in this sample. PAR30 rose from 55.70% in August to 62.61% in September, a 6.91 percentage-point increase. These are monthly snapshots of a changing active population, not evidence of a causal deterioration model.

Unclassified exposure requires data review. Six of those 13 loans are 30+ DPD; incomplete borrower fields do not make delinquency disappear. Separate missingness follow-up from the existing collections queue.

With an alternative 50% collateral haircut, illustrative loss rises from INR 782,123.00 to INR 987,738.88. That sensitivity demonstrates the effect of an assumed recovery parameter, not a validated forecast.

A useful analyst recommendation for this simulation is to inspect the largest 90+ balances first, resolve missing income/scores, and investigate the September change by product and borrower. Actual collection actions require verified records and applicable operational policies. This dataset establishes neither real borrower behavior nor company performance.
