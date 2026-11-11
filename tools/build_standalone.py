"""Assemble a single-file SAS version from the canonical CSVs and scripts."""
from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[1]
def build():
    imports=(ROOT/'sas/01_import.sas').read_text()
    for table in ['borrowers','loans','performance']:
        imports=re.sub(r'infile "&root/data/'+table+r'\.csv"[^;]*;',
          "infile datalines dsd dlm=',' truncover lrecl=32767;",imports)
        # Each DATA step ends at RUN; insert only that table's records.
        start=imports.index('data '+table+';')
        end=imports.index('run;',start)
        lines=(ROOT/'data'/f'{table}.csv').read_text().splitlines()[1:]
        imports=imports[:end]+'datalines;\n'+'\n'.join(lines)+'\n;\n'+imports[end:]
    quality=(ROOT/'sql/01_quality.sql').read_text()
    features=(ROOT/'sql/02_features.sql').read_text()
    reports=(ROOT/'sql/03_reports.sql').read_text()
    text="""/* Independent practice project inspired by Parrami Finance.
   All data are synthetic. Run this entire file in SAS Studio.
   No file paths or uploads of CSVs are required; reports remain in WORK. */
options validvarname=v7;
"""+imports+'\nproc sql noremerge;\n'+quality+"""
quit;
proc sql noprint;
 select sum(failure_count) into :qa_total trimmed from qa_failures;
quit;
%macro analyze;
 %if &qa_total ne 0 %then %do;
  %put ERROR: Mandatory data quality checks failed. Inspect WORK.QA_FAILURES.;
  %return;
 %end;
 proc sql noremerge;
"""+features+reports+"""
 quit;
 title 'Synthetic borrower credit risk: 30 September 2025';
 proc print data=qa_failures noobs; run;
 proc print data=portfolio_summary noobs; run;
 proc print data=risk_summary noobs; run;
 proc print data=collections_queue(obs=20) noobs; run;
 title;
%mend;
%analyze;
"""
    (ROOT/'sas/standalone_project.sas').write_text(text)
    print('Built sas/standalone_project.sas from canonical source files.')
if __name__=='__main__': build()
