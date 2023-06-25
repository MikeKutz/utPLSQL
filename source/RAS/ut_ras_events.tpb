create or replace type body ut_ras_events
as
  constructor function ut_ras_events(self in out nocopy ut_ras_events) return self as result
  as
  begin
    self.init($$plsql_unit,ut_output_bulk_buffer());
    return;
  end;
  
--  overriding member function get_supported_events return ut_varchar2_list
--  as
--  begin
--    return ut_varchar2_list(ut_event_manager.gc_before_suite,
--                            ut_event_manager.gc_before_test_execute,
--                            ut_event_manager.gc_after_test_execute,
--                            ut_event_manager.gc_after_suite
--                            );
--  end;
--
--  /**
--  * Delegates execution of event into individual reporting procedures
--  */
--  overriding member procedure on_event( self in out nocopy ut_ras_events, a_event_name varchar2, a_event_item ut_event_item)
--  as
--  begin
--    case a_event_name
--      when ut_event_manager.gc_before_suite then
--        self.before_calling_suite(treat(a_event_item as ut_logical_suite));
--      when ut_event_manager.gc_before_test_execute then
--        self.before_calling_test_execute(treat(a_event_item as ut_executable));
--      when ut_event_manager.gc_after_test_execute then
--        self.after_calling_test_execute(treat(a_event_item as ut_executable));
--      when ut_event_manager.gc_after_suite then
--        self.after_calling_suite(treat(a_event_item as ut_logical_suite));
--      when ut_event_manager.gc_finalize then
--        null;
--      else
--        null;
--    end case;
--  end;
  
  overriding member procedure before_calling_test(self in out nocopy ut_ras_events, a_test in ut_test)
  as
    l_results ut_varchar2_rows := ut_varchar2_rows();
    
    l_ras_user  varchar2(256) := '<none>';
  begin
    l_ras_user := a_test.object_owner || '.' || a_test.object_name || '.' || a_test.name;
  
    ut_utils.append_to_list( l_results,'  RAS: before test Execute' );
    
--    ut_utils.append_to_list( l_results,'    RASUser = "' || a_test.ras_user || '"' );
    ut_utils.append_to_list( l_results,'    RASUser = "' || l_ras_user || '"' );

    self.print_text_lines(l_results);
  end;

  overriding member procedure after_calling_test(self in out nocopy ut_ras_events, a_test in ut_test)
  as
    l_results ut_varchar2_rows := ut_varchar2_rows();
  begin
    ut_utils.append_to_list( l_results,'  RAS: after test Execute' );

    self.print_text_lines(l_results);
  end;

  /*
   * read package annotation and set globals
   */
  overriding member procedure before_calling_suite(self in out nocopy ut_ras_events, a_suite in ut_logical_suite)
  as
    l_results ut_varchar2_rows := ut_varchar2_rows();
  begin
    ut_utils.append_to_list( l_results,'RAS: before suite' );

    self.print_text_lines(l_results);
  end;

  overriding member procedure after_calling_suite(self in out nocopy ut_ras_events, a_suite in ut_logical_suite)
  as
    l_results ut_varchar2_rows := ut_varchar2_rows();
  begin
    ut_utils.append_to_list( l_results,'RAS: after auite' );

    self.print_text_lines(l_results);
  end;
  
  /*
   * destroys all RAS Sessions
  */
  member procedure on_finalize2(self in out nocopy ut_ras_events, a_run in ut_run)
  as
  begin
    dbms_output.put_line( 'RAS: on_finalize' );
  end;

  overriding member function get_description return varchar2
  as
  begin
    return 'RAS Event Processing';
  end;


end;
/
