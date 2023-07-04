create or replace
package ut_test_hr_demo
  authid current_user
as
  --%suite( RAS HR Demo )
  --%rollback(manual)
  
  --%test( daustin )
  --%xsuser( daustin )
  procedure count_daustin;

  --%test( daustin )
  --%xsuser( smavris )
  procedure count_smavris;

  --%test( nobody )
  --%disabled( CVE-2023-21829 )
  procedure count_nobody;
end;
/

  