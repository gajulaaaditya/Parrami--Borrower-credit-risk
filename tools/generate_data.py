"""Deterministic synthetic data. Python 3 standard library only."""
import csv, random
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def generate():
    r=random.Random(20261110)
    borrowers=[]; loans=[]; snapshots=[]
    for b in range(1,241):
        income=r.randrange(18000,150001,1000)
        score=r.randint(480,820)
        borrowers.append([b, ['North','South','East','West'][b%4],
          ['Salaried','Self-employed','Contract'][b%3],
          '' if b%37==0 else income, '' if b%41==0 else score,
          r.randrange(0,1101,50)])
    for n in range(1,301):
        b=(n-1)%240+1
        principal=r.randrange(5000,60001,1000)
        term=r.choice([24,36,48,60]); rate=r.choice([.09,.12,.15,.18,.24])
        monthly=rate/12
        installment=round(principal*monthly/(1-(1+monthly)**(-term)),2)
        collateral=round(principal*r.choice([0,0,.4,.8,1.2]),2)
        product=['Personal','Business','Vehicle'][n%3]
        loans.append([n,b,product,'2024-%02d-15'%((n%12)+1),principal,rate,term,installment,collateral])
        score=borrowers[b-1][4]
        for m in range(1,13):
            # Predefined scenarios guarantee boundary and closed-loan coverage.
            dpd=r.choices([0,15,30,60,90,120],[55,15,12,8,6,4])[0]
            if score!='' and score<600: dpd=min(120,dpd+30)
            if n<=6: dpd=[0,29,30,59,60,90][n-1]
            balance=round(max(0,principal*(.84-.012*m)),2)
            if n%29==0 and m>=7: balance=0; dpd=0
            days=[31,28,31,30,31,30,31,31,30,31,30,31][m-1]
            snapshots.append([n,'2025-%02d-%02d'%(m,days),balance,dpd])
    for name,header,rows in [
      ('borrowers',['borrower_id','region','employment_type','annual_income','credit_score','existing_monthly_debt'],borrowers),
      ('loans',['loan_id','borrower_id','product','origination_date','original_principal','annual_rate','term_months','scheduled_installment','collateral_value'],loans),
      ('performance',['loan_id','snapshot_date','outstanding_balance','days_past_due'],snapshots)]:
        with (ROOT/'data'/f'{name}.csv').open('w',newline='') as f:
            w=csv.writer(f); w.writerow(header); w.writerows(rows)
    print('Generated 240 borrowers, 300 loans, 3,600 monthly snapshots.')
if __name__=='__main__': generate()
