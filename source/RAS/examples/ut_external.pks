create or replace
package ut_external
  authid current_user
as
  -- asdf

  --%suite( RAS External Accounts )
  --%rollback(manual)

  --%test( External User )
  --%xsextuser( ut_tester )
  procedure i_am_here;

  --%test( External Role call 3 )
  --%xsextuser( ut_tester )
  --%xsextrole( XS_UT_EXT_1, xs_ut_ext_2 )
  --%xsextrole( xs_ut_ext_3 )
  procedure role_call_ext;

end;
/
