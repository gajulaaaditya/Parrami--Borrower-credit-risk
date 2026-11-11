# Answer guide and interview practice

The optional `sql/practice_solutions.sql` contains runnable query answers 1–18; questions 6–7 also refer to the complete source implementation in `02_features.sql`. In SAS run the optional file inside PROC SQL after the main program. It prints results without changing the analytical tables.

1–4: 240 borrowers; 300 loans; 3,600 snapshots. Sixty borrowers have two originated loans. Six incomes and five scores are missing. At the reporting date there are 290 active loans, 234 borrowers and INR 7,021,344 exposure.

5–7: DPD bucket cutoffs are 1, 30, 60 and 90. Add active installments per borrower, add existing external debt once, then divide by monthly income. Missing income produces missing DTI. Unclassified has first precedence; DPD still controls delinquency measures and can override PD to 100%.

8–18: Compare count-based 30+ incidence (59.31%) with PAR30 (62.61%): larger delinquent loans raise the balance-weighted figure. Use total portfolio balance as the product-share denominator. Count each borrower once for affordability. Use balance-weighted annual rate (15.75%) for the portfolio exposure mix. A more severe collateral haircut reduces assumed recovery and increases or leaves unchanged illustrative loss. SQL queries supply the exact product, region, trend and loan answers; do not memorize arbitrary synthetic borrower IDs.

19. The unfiltered join creates 3,600 rows for 300 originated loans. Summing those observations mixes dates, while counts repeat the same loan 12 times. Filter by date first; COUNT(DISTINCT) alone does not repair an inflated SUM.
20. SAS numeric missing values sort below ordinary numbers; SQLite NULL comparisons behave differently. Test missingness first with IS NULL and use explicit positive-income guards. A missing score must not silently become a low score or a clean approval.
21. Borrowers with two loans get twice the weight if DTI is averaged at loan grain. Use borrower_features and report the known-income denominator.
22. A snapshot 90+ DPD share measures a stock at a date. A one-year default rate needs an eligible starting population, a defined default event and an observation window. No realized default events or performance labels are supplied.
23. Balance times contractual annual rate assumes a static balance and full accrual. It excludes repayments, non-accrual, losses, funding cost and operations. It is a proxy, not earned revenue.
24. EAD is funded principal from the synthetic snapshot. PD is an arbitrary scenario assumption. LGD is calculated from invented collateral and a haircut. Their product is illustrative expected loss.
25. Later DPD would not have been known on September 30. The supplied December records exist only to test the date filter; borrower attributes are fixed by design rather than future refreshed values.
26. CASE stops at the first matching branch. Without ordered missingness checks an incomplete record can be assigned an unintended tier. Test exact threshold values, not just typical cases.
27. Add contractual due dates, cash receipts, interest/principal allocation, charge-offs, recoveries, date-effective borrower features and origination cohorts. Define status transitions and observation windows. Monthly DPD here is too simplified to infer realistic cure behavior.
28. NOREMERGE prevents SAS from automatically joining grouped summary results back to detail rows. Pre-aggregate at a clear grain and join explicitly, making intent easier to audit and port.
29. Use the sample below only after completing and understanding the project. Describe actual internship tasks separately and only if true.
30. A successful rehearsal produces identical totals and passes the quality checks without copying the feature script.

## Honest 60-second description

“I built an independent credit risk practice project inspired by lending businesses such as Parrami Finance. I generated synthetic borrower, loan and monthly performance data, then used SAS PROC SQL to join it at a fixed reporting date. I calculated debt-to-income at borrower level so multiple loans would not distort obligations, measured count-based delinquency and balance-weighted portfolio at risk, and built transparent risk segments. I also added duplicate-key checks, missing-data review and a collections report. The loss figures use invented assumptions, so I present them as a learning exercise rather than real company results.”

Say “used SAS PROC SQL” only after you have actually run that route yourself. Until then say “prepared SAS PROC SQL scripts and ran the shared queries locally in SQLite.” Do not claim you performed this analysis during your Parrami Finance internship unless a separately documented, truthful experience supports that statement.

## Optional resume wording

Borrower Credit Risk Analysis — Independent Synthetic-Data Project: Built SQL analysis of 300 synthetic loans using reporting-date joins, borrower DTI, delinquency metrics, risk segmentation and data-quality checks; prepared a SAS PROC SQL workflow and reproducible CSV reports.

After personally running SAS successfully, you can change “prepared a SAS PROC SQL workflow” to “implemented and ran the workflow in SAS PROC SQL.” No business improvement or company impact is claimed.
