/* Independent synthetic practice project inspired by Parrami Finance.
   Change ONLY root to the server folder containing README.md. No trailing slash. */
%let root=/home/YOUR_USER/borrower-credit-risk;
options validvarname=v7;
%include "&root/sas/01_import.sas";
proc sql noremerge;
%include "&root/sql/01_quality.sql";
quit;
/* Stop before analysis when mandatory quality checks fail. */
proc sql noprint;
 select sum(failure_count) into :qa_total trimmed from qa_failures;
quit;
%macro run_analysis;
 %if &qa_total ne 0 %then %do;
   %put ERROR: Mandatory data quality checks failed. Inspect WORK.QA_FAILURES.;
   %return;
 %end;
 proc sql noremerge;
 %include "&root/sql/02_features.sql";
 %include "&root/sql/03_reports.sql";
 quit;
 %include "&root/sas/03_export.sas";
%mend;
%run_analysis;
