create table portfolio_summary as
select count(*) as active_loans,count(distinct borrower_id) as active_borrowers,
 sum(outstanding_balance) as total_exposure,
 avg(dpd30_flag*1.0) as dpd30_loan_rate,avg(dpd90_flag*1.0) as dpd90_loan_rate,
 sum(case when dpd30_flag=1 then outstanding_balance else 0 end)/sum(outstanding_balance) as par30,
 sum(case when dpd90_flag=1 then outstanding_balance else 0 end)/sum(outstanding_balance) as par90,
 sum(outstanding_balance*annual_rate)/sum(outstanding_balance) as weighted_annual_rate,
 sum(annual_interest_run_rate) as annual_interest_run_rate,
 sum(illustrative_expected_loss) as illustrative_expected_loss,
 sum(illustrative_expected_loss)/sum(outstanding_balance) as expected_loss_ratio
from loan_risk;
create table risk_summary as
select risk_segment,count(*) as loans,sum(outstanding_balance) as exposure,
 avg(dpd30_flag*1.0) as dpd30_loan_rate,
 sum(illustrative_expected_loss) as illustrative_expected_loss
from loan_risk group by risk_segment;
create table product_summary as
select product,count(*) as loans,sum(outstanding_balance) as exposure,
 sum(case when dpd30_flag=1 then outstanding_balance else 0 end)/sum(outstanding_balance) as par30,
 sum(illustrative_expected_loss) as illustrative_expected_loss
from loan_risk group by product;
create table region_summary as
select region,count(*) as loans,count(distinct borrower_id) as borrowers,
 sum(outstanding_balance) as exposure,
 sum(case when dpd90_flag=1 then outstanding_balance else 0 end)/sum(outstanding_balance) as par90
from loan_risk group by region;
/* Ratios at borrower grain: do not average repeated borrower DTIs from loan_risk. */
create table affordability_summary as
select count(*) as active_borrowers,count(dti) as known_dti_borrowers,
 avg(dti) as mean_known_dti,
 sum(case when dti>0.50 then 1 else 0 end)*1.0/count(dti) as over50_share_of_known
from borrower_features;
create table monthly_trend as
select p.snapshot_date,count(*) as active_loans,sum(p.outstanding_balance) as exposure,
 sum(case when p.days_past_due>=30 then p.outstanding_balance else 0 end)/sum(p.outstanding_balance) as par30,
 sum(case when p.days_past_due>=90 then p.outstanding_balance else 0 end)/sum(p.outstanding_balance) as par90
from performance p inner join loans l on p.loan_id=l.loan_id
where p.snapshot_date<='2025-09-30' and l.origination_date<=p.snapshot_date
 and p.outstanding_balance>0 group by p.snapshot_date;
create table collections_queue as
select loan_id,borrower_id,product,days_past_due,outstanding_balance,risk_segment,
 illustrative_expected_loss from loan_risk where days_past_due>=30
order by days_past_due desc,outstanding_balance desc,loan_id;
