# Data dictionary

No names, contact details, protected demographic fields, real identifiers or company data are included.

## borrowers.csv — one row per borrower

Primary key: `borrower_id`. 240 rows.

| Field | Type in SAS | Meaning |
|---|---|---|
| borrower_id | Numeric | Synthetic borrower key, 1–240 |
| region | Character 5 | Fictional geographic grouping: North, South, East, West |
| employment_type | Character 13 | Salaried, Self-employed, Contract; descriptive only |
| annual_income | Numeric | Annual gross INR income; blank for six borrowers |
| credit_score | Numeric | Invented credit score, 480–820 when known; blank for five |
| existing_monthly_debt | Numeric | Monthly obligations outside the project loans, INR |

Blank CSV numeric fields become SAS numeric missing / SQLite NULL. Monthly income is annual_income / 12. There is no literal string `NULL` in inputs.

## loans.csv — one row per loan

Primary key: `loan_id`. Foreign key: `borrower_id → borrowers`. 300 rows; 60 borrowers have two originated loans.

| Field | Type in SAS | Meaning |
|---|---|---|
| loan_id | Numeric | Synthetic loan key, 1–300 |
| borrower_id | Numeric | Borrower owning the loan |
| product | Character 8 | Personal, Business, Vehicle |
| origination_date | Character 10 | ISO origination date, all in 2024 |
| original_principal | Numeric | Original INR principal |
| annual_rate | Numeric | Contract annual interest rate as fraction |
| term_months | Numeric | Original term: 24, 36, 48 or 60 months |
| scheduled_installment | Numeric | Original level monthly repayment, rounded to paise |
| collateral_value | Numeric | Synthetic gross collateral value; zero means unsecured |

Installment formula: `P*r/(1-(1+r)^(-n))`, where r = annual_rate / 12. Collateral and borrower attributes are fixed for the demonstration; production reporting would need date-effective attributes and valuations.

## performance.csv — one row per loan per month end

Composite primary key: `(loan_id, snapshot_date)`. Foreign key: `loan_id → loans`. 3,600 rows.

| Field | Type in SAS | Meaning |
|---|---|---|
| loan_id | Numeric | Loan reference |
| snapshot_date | Character 10 | ISO month end, January–December 2025 |
| outstanding_balance | Numeric | INR principal outstanding; zero means inactive for this analysis |
| days_past_due | Numeric | Integer DPD at that month end |

Balances follow a simplified declining path; they are not calculated from a cash-flow ledger. DPD is randomly assigned each month with deliberately controlled boundary cases on loans 1–6. These observations cannot support a realistic cure/roll-rate model or calibrated default model.

## Derived table grains

`active_loans`, `loan_features`, `loan_risk`, `collections_queue`: one row per loan at the reporting date (queue is a subset). `borrower_obligations`, `borrower_features`: one row per active borrower. `monthly_trend`: one row per observed month through reporting date. Other summary tables: one row per named grouping, or a single portfolio/profile/affordability row. `qa_failures`: one row per mandatory check.
