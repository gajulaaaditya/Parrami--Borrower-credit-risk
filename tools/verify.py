"""Outcome checks plus hand-calculated edge cases; no external packages."""
import math
from run_local import run
c=run()
def scalar(q): return c.execute(q).fetchone()[0]
assert scalar('select sum(failure_count) from qa_failures')==0
assert scalar('select count(*) from borrowers')==240
assert scalar('select count(*) from loans')==300
assert scalar('select count(*) from performance')==3600
assert scalar('select count(*) from loan_risk')==290
assert scalar('select count(distinct loan_id) from loan_risk')==290
assert scalar("select count(*) from monthly_trend where snapshot_date>'2025-09-30'")==0
assert scalar('select count(*) from monthly_trend')==9
assert scalar('select count(*) from loan_risk where outstanding_balance<=0')==0
assert scalar('select count(*) from loan_risk where assumed_pd<0 or assumed_pd>1 or assumed_lgd<0 or assumed_lgd>1')==0
assert scalar('select count(*) from loan_risk where illustrative_expected_loss<0 or illustrative_expected_loss>outstanding_balance')==0
exposure=scalar('select sum(outstanding_balance) from loan_risk')
assert math.isclose(exposure,scalar('select sum(exposure) from risk_summary'))
assert math.isclose(exposure,scalar('select sum(exposure) from product_summary'))
assert math.isclose(exposure,scalar('select sum(exposure) from region_summary'))
assert scalar('select missing_income from data_quality_profile')==6
assert scalar('select missing_credit_score from data_quality_profile')==5
# Hand-check borrower 1: two active loan obligations, one existing debt amount.
b=c.execute('select annual_income,existing_monthly_debt from borrowers where borrower_id=1').fetchone()
inst=scalar('select sum(scheduled_installment) from active_loans where borrower_id=1')
assert math.isclose((b[1]+inst)/(b[0]/12),scalar('select dti from borrower_features where borrower_id=1'))
# Hand-check threshold boundaries on six controlled loans.
expected=['Current','1-29 DPD','30-59 DPD','30-59 DPD','60-89 DPD','90+ DPD']
assert [x[0] for x in c.execute('select delinquency_bucket from loan_risk where loan_id<=6 order by loan_id')]==expected
# Independent tiny scenario: 100 current + 300 at 30DPD => 50% count rate, 75% PAR30.
ead=[100,300]; flags=[0,1]
assert sum(flags)/len(flags)==.5
assert sum(x*f for x,f in zip(ead,flags))/sum(ead)==.75
# 1,000 EAD, 500 collateral, 30% haircut: LGD=.65, PD=.12 => EL=78.
assert math.isclose(1000*.12*(1-.70*500/1000),78)
# Missing-income borrower must not become a low-risk record.
assert scalar("select count(*) from loan_risk where annual_income is null and risk_segment<>'Unclassified'")==0
# Inject a duplicate snapshot and confirm quality gate catches it.
c.execute('insert into performance select * from performance limit 1')
c.execute('drop table qa_failures'); c.execute('drop table data_quality_profile')
from run_local import ROOT
c.executescript((ROOT/'sql/01_quality.sql').read_text())
assert scalar("select failure_count from qa_failures where check_name='duplicate_snapshot_key'")==1
print('PASS: row counts, unique grain, reconciliation, missingness, DTI, DPD boundaries, loss bounds, future exclusion and duplicate detection.')
