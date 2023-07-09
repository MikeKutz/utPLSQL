create or replace
package body ut_external
as
  procedure i_am_here
  as
  begin
    ut.expect(1).to_equal(1);
  end;

  procedure role_call_ext
  as
    n int := 0;
  begin
    /* method is for debugging */
      select count(*) into n
      from v$xs_session_roles a
      where a.role_name in ( upper( 'xs_ut_ext_1' )
            ,upper( 'xs_ut_ext_2' ), upper( 'xs_ut_ext_3' ) );
    
    ut.expect( n ).to_equal( 3 );
  end;

end;
/
