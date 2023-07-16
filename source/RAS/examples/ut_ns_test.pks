create or replace
package ut_ns
  authid current_user
as
  /* This Unit Test packag demonstrate usage of RAS Namespace
   *
   * also: shows bug of case-sensitive xs_sys_namespaca
   */

  --%suite( NS Tests )
  --%rollback(manual)
  
  --%test( Context Copy )
  --%xsuser( daustin )
  procedure context_test;

  --%test( XS Context Set )
  --%xsuser( daustin )
  --%xsnsattr( ut_test_ns, attr1, hello world )
  --%xsnsattr( ut_test_ns, attr2, this is the way )
  procedure context_test2;
  
  --%test( Stateless Test )
  --%xsuser( daustin )
  procedure stateless_contex;
  
  --%test( Overwrite NS Attributes )
  --%xsuser( daustin )
  --%xsnsattr( ut_test_ns, attr1, marco )
  --%xsnsattr( ut_test_ns, attr2, polo )
  procedure context_overwrite;

  --%test( Statelessness of Overwrite )
  --%xsuser( daustin )
  procedure context_overwrite_stateless;

  --%test( Test for XS NS Case Sensitive bug )
  --%xsuser( daustin )
  --%xsnsattr( ut_test_ns, attr1, marco )
  --%xsnsattr( ut_test_ns, attr2, polo )
  procedure xs_ns_bug;
  
  
end;
/

grant execute on ut_ns to public;