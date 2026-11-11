# Financial metrics and teaching rules

Reporting date: 2025-09-30. Active = positive principal outstanding and originated on/before the snapshot date. Zero balances are excluded, regardless of original principal. Every ratio below uses the active population unless stated otherwise. Currency is synthetic INR.

| Metric / column | Definition | Interpretation |
|---|---|---|
| total_exposure / exposure | Sum of outstanding principal | Funded exposure at the reporting date |
| active_loans | Count of active loan rows | Loan count, not borrower count |
| active_borrowers | Count distinct borrower_id | Unique people with an active loan |
| dti | (Existing monthly debt + all active project installments) / (annual gross income / 12) | Borrower monthly debt-to-income; unknown when income missing |
| dpd30_loan_rate | Count loans with DPD >= 30 / active loan count | Unweighted loan incidence |
| dpd90_loan_rate | Count loans with DPD >= 90 / active loan count | Severe delinquency incidence; not a historical default rate |
| par30 | Outstanding principal on loans with DPD >= 30 / total outstanding principal | Portfolio at risk, balance-weighted; includes entire affected loan balance |
| par90 | Outstanding principal on loans with DPD >= 90 / total outstanding principal | Severe delinquency exposure share |
| weighted_annual_rate | Sum(balance * annual_rate) / sum(balance) | Balance-weighted contractual rate |
| annual_interest_run_rate | Sum(balance * annual_rate) | Static annualized contractual interest proxy, before non-accrual, costs and losses |
| assumed_lgd | max(0, 1 - 0.70 * collateral_value / balance) | Hypothetical loss severity with a 30% collateral haircut |
| illustrative_expected_loss | balance * assumed_pd * assumed_lgd | Teaching loss estimate under invented assumptions |
| expected_loss_ratio | Sum(illustrative expected loss) / total exposure | Hypothetical portfolio loss share |
| mean_known_dti | Average borrower DTI, excluding missing | Each borrower counted once; known_dti_borrowers reports the denominator |

Rates are fractions. A 0.35 DTI means 35%. PAR30 and PAR90 use inclusive thresholds (>=30 and >=90). Loan 2 at 29 days is below PAR30; loan 3 at exactly 30 is included. Monthly trend metrics recompute each month's active population; do not sum monthly balances into a point-in-time exposure.

## Risk segmentation, in priority order

1. **Unclassified:** income/DTI or credit score is missing, regardless of delinquency. This precedence makes data completeness visible. Its DPD still contributes to delinquency reports and collections.
2. **High:** DPD >=30, credit score <600, or DTI >50%.
3. **Medium:** DPD >0, credit score <700, or DTI >35%.
4. **Low:** remaining complete records.

Exactly 50% DTI is not High on DTI alone; exactly 35% is not Medium on DTI alone. Exactly 600 credit score is not High on score alone; exactly 700 is not Medium on score alone. Region and employment do not determine the segment. This is a transparent practice rule, not a validated underwriting policy or lending recommendation.

## Hypothetical loss assumptions

DPD >=90 receives assumed PD = 100%, including Unclassified records. Otherwise PD is 8% for Unclassified, 12% High, 4% Medium, 1% Low. The 8% incomplete-data assumption is arbitrary, not a calibrated conservative estimate. These are invented one-year scenario probabilities, not probabilities estimated from the snapshots. They intentionally use current delinquency, so do not present this as an origination-time predictive model.

EAD is principal outstanding only; no undrawn facilities, accrued interest or fees. LGD caps assumed net collateral recovery at EAD, so loss never becomes negative. There are no recovery costs, time-to-recovery effects, discounting, cure assumptions, guarantees or collateral-sharing complications. A 90+ DPD loan can have zero illustrative loss if assumed collateral fully covers its balance; this does not establish real recoverability.

The loss estimate is not an IFRS 9, CECL, Basel, accounting provision or validated forecast. No realized defaults, charge-offs, recoveries or repayment cash flows are supplied. Do not label the interest run rate as recognized revenue, profit, cash collection, yield-to-maturity or net interest margin. DTI uses gross reported income rather than verified disposable income.

## Data realism limits

The synthetic sample deliberately has high delinquency to make segmentation exercises interesting. Borrower attributes are static and monthly DPD transitions are simplified. Percentages cannot be used to describe Parrami Finance or any actual lender. A production extension would need effective-dated borrower data, a repayment ledger, historical outcomes, cohort definitions and calibrated/validated assumptions.
