create or replace
package body ut_test_hr_demo
as
  function count_employees return int
  as
    n int;
  begin
    select count(*) into n
    from hr.employees;
    
    return n;
  end;
  
  --%test( daustin )
  procedure count_daustin
  as
  begin
    ut.expect( count_employees ).to_equal( 5 );
  end;

  --%test( daustin )
  procedure count_smavris
  as
  begin
    ut.expect( count_employees ).to_equal( 107 );
  end;
  
  --%test( daustin )
  --%disabled( CVE-2023-21829 )
  procedure count_nobody
  as
  begin
    ut.expect( count_employees ).to_equal( 0 );
  end;

  procedure init
  as
  begin
    null;
--    ut_xs_session_manager.destroy_all_sessions;
  end;
  
  --%afterall
  procedure destroy
  as
  begin
    null;
--    ut_xs_session_manager.destroy_all_sessions;
  end;
end;
/

  