/* Fixed reporting date; future performance is deliberately excluded. */
create table active_loans as
select l.*,p.snapshot_date,p.outstanding_balance,p.days_past_due
from loans l inner join performance p on l.loan_id=p.loan_id
where p.snapshot_date='2025-09-30' and l.origination_date<=p.snapshot_date
 and p.outstanding_balance>0;
/* Aggregate loan obligations BEFORE joining borrower features. */
create table borrower_obligations as
select borrower_id,count(*) as active_loan_count,
 sum(scheduled_installment) as project_monthly_installments,
 sum(outstanding_balance) as borrower_exposure
from active_loans group by borrower_id;
create table borrower_features as
select b.*,o.active_loan_count,o.project_monthly_installments,o.borrower_exposure,
 case when b.annual_income is not null and b.annual_income>0
 then (b.existing_monthly_debt+o.project_monthly_installments)/(b.annual_income/12.0)
 end as dti
from borrowers b inner join borrower_obligations o on b.borrower_id=o.borrower_id;
create table loan_features as
select a.*, b.region,b.employment_type,b.annual_income,b.credit_score,b.dti,
 case when a.days_past_due>=90 then '90+ DPD'
      when a.days_past_due>=60 then '60-89 DPD'
      when a.days_past_due>=30 then '30-59 DPD'
      when a.days_past_due>0 then '1-29 DPD' else 'Current' end as delinquency_bucket,
 case when a.days_past_due>=30 then 1 else 0 end as dpd30_flag,
 case when a.days_past_due>=90 then 1 else 0 end as dpd90_flag,
 case when b.credit_score is null or b.dti is null then 'Unclassified'
      when a.days_past_due>=30 or b.credit_score<600 or b.dti>0.50 then 'High'
      when a.days_past_due>0 or b.credit_score<700 or b.dti>0.35 then 'Medium'
      else 'Low' end as risk_segment,
 /* Teaching assumptions, NOT fitted or validated probabilities. */
 case when a.days_past_due>=90 then 1.00
      when b.credit_score is null or b.dti is null then 0.08
      when a.days_past_due>=30 or b.credit_score<600 or b.dti>0.50 then 0.12
      when a.days_past_due>0 or b.credit_score<700 or b.dti>0.35 then 0.04
      else 0.01 end as assumed_pd,
 case when 0.70*a.collateral_value>=a.outstanding_balance then 0
      else 1.0-0.70*a.collateral_value/a.outstanding_balance end as assumed_lgd
from active_loans a inner join borrower_features b on a.borrower_id=b.borrower_id;
create table loan_risk as
select f.*, outstanding_balance*assumed_pd*assumed_lgd as illustrative_expected_loss,
 outstanding_balance*annual_rate as annual_interest_run_rate
from loan_features f;
