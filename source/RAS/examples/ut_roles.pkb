create or replace
package body ut_roles
as
  
  procedure role_call
  as
    n int;
  begin
    select count(*) into n
    from v$xs_session_roles a
    where a.role_name in ( upper( 'xs_ut_role' ) );
    
    ut.expect( n ).to_equal( 1 );
  end;
  
  procedure role_call2
  as
    n int;
  begin
    select count(*) into n
    from v$xs_session_roles a
    where a.role_name in ( upper( 'xs_ut_role' )
          ,upper( 'xs_ut_2' ), upper( 'xs_ut_3' ) );
    
    ut.expect( n ).to_equal( 3 );
  end;

  procedure role_call_stateless
  as
  begin
    role_call2;
  end;

end;
/
