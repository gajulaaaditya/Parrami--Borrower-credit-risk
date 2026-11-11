/* Optional: run after the main pipeline. In SAS, surround this file with
   PROC SQL NOREMERGE; %include "&root/sql/practice_solutions.sql"; QUIT; */
/* 1 */
select count(*) as borrowers from borrowers;
select count(*) as loans from loans;
select count(*) as snapshots from performance;
/* 2 */
select borrower_id,count(*) as loans from loans group by borrower_id having count(*)>1;
/* 3 */
select * from borrowers where annual_income is null or credit_score is null;
/* 4: active_loans in 02_features.sql is the complete source-level answer. */
select count(*) as active_loans,sum(outstanding_balance) as exposure from active_loans;
/* 5 */
select delinquency_bucket,count(*) as loans from loan_risk group by delinquency_bucket;
/* 6,7: inspect source-level construction in 02_features.sql. */
select borrower_id,project_monthly_installments,existing_monthly_debt,annual_income,dti
from borrower_features order by borrower_id;
select risk_segment,count(*) as loans from loan_risk group by risk_segment;
/* 8 */
select avg(dpd30_flag*1.0) as loan_rate,
 sum(case when dpd30_flag=1 then outstanding_balance else 0 end)/sum(outstanding_balance) as par30
from loan_risk;
/* 9: scalar denominator avoids detail/summary remerging. */
select product,sum(outstanding_balance) as exposure,
 sum(outstanding_balance)/(select sum(outstanding_balance) from loan_risk) as exposure_share
from loan_risk group by product;
/* 10 */
select region,
 sum(case when dpd90_flag=1 then outstanding_balance else 0 end)/sum(outstanding_balance) as par90
from loan_risk group by region
having sum(case when dpd90_flag=1 then outstanding_balance else 0 end)/sum(outstanding_balance)>0.15;
/* 11 */
select * from borrower_features where dti is not null and dti>0.50;
/* 12 */
select avg(annual_rate) as simple_rate,
 sum(outstanding_balance*annual_rate)/sum(outstanding_balance) as weighted_rate from loan_risk;
/* 13 */
select loan_id,outstanding_balance from loan_risk where days_past_due>=30
 and outstanding_balance=(select max(outstanding_balance) from loan_risk where days_past_due>=30);
/* 14 */
select a.par30 as august_par30,b.par30 as september_par30,
 (b.par30-a.par30)*100 as change_percentage_points
from monthly_trend a inner join monthly_trend b on a.snapshot_date='2025-08-31'
 and b.snapshot_date='2025-09-30';
/* 15 */
select loan_id,days_past_due,credit_score,annual_income from loan_risk
where risk_segment='Unclassified' and days_past_due>=90;
/* 16 */
select * from collections_queue order by days_past_due desc,outstanding_balance desc,loan_id;
/* 17 */
select sum(exposure)-(select total_exposure from portfolio_summary) as difference from product_summary;
/* 18 */
select sum(outstanding_balance*assumed_pd*
 case when 0.50*collateral_value>=outstanding_balance then 0
      else 1.0-0.50*collateral_value/outstanding_balance end) as loss_50pct_haircut,
 sum(illustrative_expected_loss) as base_loss from loan_risk;
