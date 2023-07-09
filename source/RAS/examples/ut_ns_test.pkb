create or replace
package body ut_ns
as
  function xsv( xs_ns in varchar2, xs_attrib in varchar2 ) return varchar2
  as
    l_return_value varchar2(200);
  begin
    select xs_sys_context( xs_ns, xs_attrib )
      into l_return_value
    from dual;
    
    return l_return_value;
  end;

  procedure context_test
  as
  begin
    ut.expect( xsv( 'UT3_INFO', 'SUITE_PACKAGE' ) ).to_equal( $$PLSQL_UNIT_OWNER || '.' || lower( $$PLSQL_UNIT  ) );
  end;
  
  procedure context_test2
  as
  begin
    ut.expect( xsv( upper('ut_test_ns'), 'attr1' ) ).to_equal( 'hello world' );
    ut.expect( xsv( upper('ut_test_ns'), 'attr2' ) ).to_equal( 'this is the way' );
  end;
  procedure stateless_contex
  as
  begin
    context_test2;
  end;
  
  procedure context_overwrite
  as
  begin
    ut.expect( xsv( upper('ut_test_ns'), 'attr1' ) ).to_equal( 'marco' );
    ut.expect( xsv( upper('ut_test_ns'), 'attr2' ) ).to_equal( 'polo' );
  end;

  procedure context_overwrite_stateless
  as
  begin
    context_overwrite;
  end;

  procedure xs_ns_bug
  as
    ns       constant varchar2(20) := 'ut_test_ns';
    att      constant varchar2(20) := 'attR1';
    expected constant varchar2(20) := 'marco';

    function as_is( txt in varchar2 ) return varchar2
    as
    begin
      return txt;
    end;
  begin
    ut.expect( xsv(  upper(ns) , upper(att) ) ).to_equal( expected );
    ut.expect( xsv(  upper(ns) , lower(att) ) ).to_equal( expected );
    ut.expect( xsv(  upper(ns) , as_is(att) ) ).to_equal( expected );
    ut.expect( xsv(  upper(ns) , initcap(att) ) ).to_equal( expected );

    ut.expect( xsv(  lower(ns) , upper(att) ) ).to_equal( expected );
    ut.expect( xsv(  lower(ns) , lower(att) ) ).to_equal( expected );
    ut.expect( xsv(  lower(ns) , as_is(att) ) ).to_equal( expected );
    ut.expect( xsv(  lower(ns) , initcap(att) ) ).to_equal( expected );

    ut.expect( xsv(  as_is(ns) , upper(att) ) ).to_equal( expected );
    ut.expect( xsv(  as_is(ns) , lower(att) ) ).to_equal( expected );
    ut.expect( xsv(  as_is(ns) , as_is(att) ) ).to_equal( expected );
    ut.expect( xsv(  as_is(ns) , initcap(att) ) ).to_equal( expected );

    ut.expect( xsv(  initcap(ns) , upper(att) ) ).to_equal( expected );
    ut.expect( xsv(  initcap(ns) , lower(att) ) ).to_equal( expected );
    ut.expect( xsv(  initcap(ns) , as_is(att) ) ).to_equal( expected );
    ut.expect( xsv(  initcap(ns) , initcap(att) ) ).to_equal( expected );
  end;

end;
/
