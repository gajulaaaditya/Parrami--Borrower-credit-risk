"""Run the SAME SQL in SQLite for a zero-dependency local practice option."""
import csv, sqlite3, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
REPORTS=['qa_failures', 'data_quality_profile', 'portfolio_summary', 'risk_summary', 'product_summary', 'region_summary', 'affordability_summary', 'monthly_trend', 'collections_queue', 'borrower_features', 'loan_risk']
def run():
    con=sqlite3.connect(':memory:')
    schemas={
      'borrowers':'borrower_id integer, region text, employment_type text, annual_income real, credit_score integer, existing_monthly_debt real',
      'loans':'loan_id integer, borrower_id integer, product text, origination_date text, original_principal real, annual_rate real, term_months integer, scheduled_installment real, collateral_value real',
      'performance':'loan_id integer, snapshot_date text, outstanding_balance real, days_past_due integer'}
    for table,schema in schemas.items():
        con.execute(f'create table {table} ({schema})')
        with (ROOT/'data'/f'{table}.csv').open(newline='') as f:
            reader=csv.reader(f); cols=next(reader)
            con.executemany(f'insert into {table} values ({",".join("?" for _ in cols)})',
                            ([None if x=='' else x for x in row] for row in reader))
    for script in sorted((ROOT/'sql').glob('0*.sql')):
        con.executescript(script.read_text())
        if script.name.startswith('01'):
            failures=con.execute('select * from qa_failures where failure_count>0').fetchall()
            if failures: raise ValueError(f'Data quality failures: {failures}')
    return con

def export(con):
    folder=ROOT/'results'; folder.mkdir(exist_ok=True)
    for table in REPORTS:
        order={'collections_queue':' order by days_past_due desc,outstanding_balance desc,loan_id',
               'monthly_trend':' order by snapshot_date'}.get(table,'')
        cur=con.execute('select * from '+table+order)
        with (folder/f'{table}.csv').open('w',newline='') as f:
            w=csv.writer(f); w.writerow([d[0] for d in cur.description]); w.writerows(cur)
    cur=con.execute('select * from portfolio_summary')
    print(json.dumps(dict(zip([d[0] for d in cur.description],cur.fetchone())),indent=2))
if __name__=='__main__': export(run())
