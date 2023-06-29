create or replace
package ut_test_hr_demo
  authid current_user
as
  --%suite( RAS HR Demo )
  
  --%test( daustin )
  procedure count_daustin;

  --%test( daustin )
  procedure count_smavris;

  --%test( nobody )
  --%disabled( CVE-2023-21829 )
  procedure count_nobody;
  
  --%beforeall
  procedure init;
  
  --%afterall
  procedure destroy;
end;
/

  