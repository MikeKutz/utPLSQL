create or replace
package ut_roles
  authid current_user
as
  --a
  
  --%suite( RAS Roles )
  --%rollback(manual)

  --%test( Internal Role call 1x )
  --%xsuser( daustin )
  --%xsrole( xs_ut_role )
  procedure role_call;

  --%test( Internal Role call 3x )
  --%xsuser( daustin )
  --%xsrole( xs_ut_role, xs_ut_2 )
  --%xsrole( xs_ut_3 )
  procedure role_call2;
  
  --%test( Stateless Role Call )
  --%xsuser( daustin )
  procedure role_call_stateless;
  
end;
/

grant execute on ut_external to public;
