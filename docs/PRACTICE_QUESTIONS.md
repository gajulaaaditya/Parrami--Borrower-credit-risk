# Practice questions

Work from the supplied CSVs. First answer without looking at the solutions; then explain the grain and denominator aloud. Run the main pipeline before querying derived tables.

## SQL exercises

1. Count borrowers, loans and monthly observations. Identify each table's primary key.
2. Find borrowers with more than one originated loan using GROUP BY and HAVING.
3. Identify missing income and credit scores without treating missing values as zero.
4. Recreate active loan exposure at 30 September 2025 with an INNER JOIN and a date filter.
5. Show the five DPD buckets and their loan counts.
6. Calculate borrower DTI from the source tables. Why aggregate installments before the borrower join?
7. Explain and reproduce the ordered CASE logic for all four risk segments.
8. Compute PAR30 and the 30+ DPD count rate together. Why do they differ?
9. Calculate product exposure and each product's share of portfolio exposure.
10. List regions with PAR90 above 15% using HAVING.
11. Find active borrowers with no missing income and DTI above 50%.
12. Compute a balance-weighted contractual rate. Compare it with the simple average rate.
13. Find the largest overdue balance using a subquery; return ties.
14. Compare August and September PAR30 using a self join. Express the change in percentage points.
15. Show loans requiring data review even though they are already 90+ DPD.
16. Select the collections queue sorted by DPD, then balance, then loan ID.
17. Reconcile the sum of product exposures to the portfolio total.
18. Recalculate illustrative losses with a 50% collateral haircut. Explain why they can only increase or stay unchanged.

## Debugging and interview discussion

19. What happens if you join loans to all performance rows and count loans? Demonstrate the duplication.
20. Why does SAS numeric missingness need explicit guards in threshold conditions? What happens if missing credit scores are classified as scores below 600?
21. Why would averaging DTI on the loan-level table weight some borrowers twice?
22. Does a 90+ DPD ratio equal a one-year default rate? What outcome data is missing?
23. Why is annualized interest run rate not actual revenue or profit?
24. What is the difference between EAD, PD and LGD? Which are observed and which are invented here?
25. How could using December performance to explain September risk introduce leakage?
26. Why do CASE precedence and exact threshold boundaries matter?
27. What additional data would you need for observed default rates, vintage analysis and a realistic collections strategy?
28. What does PROC SQL NOREMERGE help detect? Why avoid relying on automatic remerging?
29. Describe this practice project honestly in 60 seconds, keeping it separate from your internship experience.
30. Starting with empty WORK tables, recreate import → quality → joins → DTI → segmentation → reports in under 30 minutes.

## Three-session rehearsal

- Session 1: write joins and grouping from scratch; explain keys and the risk of row multiplication.
- Session 2: implement DTI, DPD buckets, risk CASE expressions, weighted metrics and missingness handling.
- Session 3: recreate the project without notes, explain reference findings, then answer questions 19–29 aloud.

This project does not reproduce your separate SAS assignment, whose instructions and data were not supplied. Practice that assignment independently using its actual requirements.
