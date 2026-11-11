/* Every row of qa_failures must have failure_count = 0. */
create table qa_failures as
select cast('duplicate_borrower_key' as char(32)) as check_name, count(*) as failure_count from
 (select borrower_id from borrowers group by borrower_id having count(*)>1) x
union all select 'duplicate_loan_key', count(*) from
 (select loan_id from loans group by loan_id having count(*)>1) x
union all select 'duplicate_snapshot_key', count(*) from
 (select loan_id,snapshot_date from performance group by loan_id,snapshot_date having count(*)>1) x
union all select 'orphan_loans',count(*) from loans l left join borrowers b
 on l.borrower_id=b.borrower_id where b.borrower_id is null
union all select 'orphan_snapshots',count(*) from performance p left join loans l
 on p.loan_id=l.loan_id where l.loan_id is null
union all select 'invalid_loan_values',count(*) from loans where
 original_principal is null or original_principal<=0 or annual_rate is null or annual_rate<0
 or scheduled_installment is null or scheduled_installment<=0 or term_months is null or term_months<=0
 or collateral_value is null or collateral_value<0
union all select 'invalid_snapshot_values',count(*) from performance where
 outstanding_balance is null or outstanding_balance<0 or days_past_due is null or days_past_due<0
union all select 'missing_asof_snapshot',count(*) from loans l left join performance p
 on l.loan_id=p.loan_id and p.snapshot_date='2025-09-30'
 where l.origination_date<='2025-09-30' and p.loan_id is null
union all select 'invalid_borrower_values',count(*) from borrowers where
 (annual_income is not null and annual_income<=0) or
 (credit_score is not null and (credit_score<300 or credit_score>850)) or
 existing_monthly_debt is null or existing_monthly_debt<0;
/* Expected missingness is reported separately; never replace income with zero. */
create table data_quality_profile as
select count(*) as borrowers, sum(case when annual_income is null then 1 else 0 end) as missing_income,
 sum(case when credit_score is null then 1 else 0 end) as missing_credit_score from borrowers;
