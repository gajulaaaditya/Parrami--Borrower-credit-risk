/* Explicit schema avoids PROC IMPORT type-guessing differences.
   ISO dates remain fixed-width character values for portable SQL comparisons. */
data borrowers;
 length borrower_id annual_income credit_score existing_monthly_debt 8
        region $5 employment_type $13;
 infile "&root/data/borrowers.csv" dsd dlm=',' firstobs=2 truncover lrecl=32767;
 input borrower_id region :$5. employment_type :$13.
       annual_income credit_score existing_monthly_debt;
run;
data loans;
 length loan_id borrower_id original_principal annual_rate term_months
        scheduled_installment collateral_value 8 product $8 origination_date $10;
 infile "&root/data/loans.csv" dsd dlm=',' firstobs=2 truncover lrecl=32767;
 input loan_id borrower_id product :$8. origination_date :$10.
       original_principal annual_rate term_months scheduled_installment collateral_value;
run;
data performance;
 length loan_id outstanding_balance days_past_due 8 snapshot_date $10;
 infile "&root/data/performance.csv" dsd dlm=',' firstobs=2 truncover lrecl=32767;
 input loan_id snapshot_date :$10. outstanding_balance days_past_due;
run;
