create or replace
package body ut_test_hr_demo
as
  r  ut_ras := new ut_ras();
  
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
    r.attach_session( 'daustin' );
  
    ut.expect( count_employees ).to_equal( 5 );
    
    r.detach_session;
  end;

  --%test( daustin )
  procedure count_smavris
  as
  begin
    r.attach_session( 'smavris' );
  
    ut.expect( count_employees ).to_equal( 107 );
    
    r.detach_session;
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
  end;
  
  --%afterall
  procedure destroy
  as
  begin
    if r is not null
    then
      r.destroy_all_sessions;
    end if;
  end;
end;
/

  