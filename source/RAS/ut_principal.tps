create or replace type ut_principal authid current_user as object (
  principal_name    varchar2(128),
  is_external       number(1),
  unique_identifier varchar2(128),
  constructor function ut_principal return self as result,
  constructor function ut_principal( username in varchar2 ) return self as result,
  member procedure parse( self in out nocopy ut_principal, username in varchar2 ),
  member function to_string return varchar2
) final;
