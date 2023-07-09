create or replace
package body ut_ras_utils
as
  /* "source of truth" for all RAS functionality */
  
  function is_ras_session return boolean
  as
    a_session_id  varchar2( 64 );
  begin
    select xs_sys_context( 'xs$session', 'session_id')
      into a_session_id
    from dual;
    
    return case when a_session_id is not null then true else false end;
  end;
  
  procedure ad_hoc_attach( a_session in ut_ras_session_info )
  as
  begin
    
    if a_session is null then return; end if;
    if a_session.principal.principal_name is null
      or a_session.sessionid is null
      or a_session.disabled = 1
    then
      return;
    end if;
    
    dbms_xs_sessions.attach_session( a_session.sessionid
                                    ,enable_dynamic_roles => ut_ras_utils.ut_role_to_xs_role( a_session.enabled_roles )
                                    ,external_roles => ut_ras_utils.ut_role_to_xs_role( a_session.external_roles )
                                    ,namespaces => ut_ras_utils.ut_attrib_to_xs_attrib( a_session.ns_attrib_list ) );
  end;
  
  procedure detach_session( a_abort in boolean default false)
  as
    l_expectation_results  ut_expectation_results;
    l_pos  int;
  begin
    if is_ras_session
    then
      l_expectation_results := ut_expectation_processor.get_all_expectations;

      dbms_xs_sessions.save_session;
      dbms_xs_sessions.detach_session( a_abort );

      l_pos := l_expectation_results.first;
      if l_expectation_results is not null
      then
        
--        dbms_output.put_line( 'RAS expectation N="' || ut_expectation_processor.get_all_expectations().count || '"' );
        
        while( l_pos is not null )
        loop
          ut_expectation_processor.add_expectation_result( l_expectation_results( l_pos ) );
          
          l_pos := l_expectation_results.next( l_pos );
        end loop;
      end if;
    end if;
  end;
  
  function get_context_values return ut_ns_attrib_list
  as
    l_attrib_list   ut_varchar2_list;
    l_return_value  ut_ns_attrib_list := new ut_ns_attrib_list();
  begin
    l_attrib_list := ut_session_context.list_attributes();
    
    l_return_value.extend( l_attrib_list.count );
    
    for i in 1 .. l_attrib_list.count
    loop
      l_return_value(i) := new ut_ns_attrib( ut_session_context.get_namespace(), l_attrib_list(i), sys_context( ut_session_context.get_namespace(), l_attrib_list(i) ) );
    end loop;
    
    return l_return_value;
  end;

  function ut_attrib_to_xs_attrib( a_ut_vals in ut_ns_attrib_list) return dbms_xs_nsattrlist
  as
    l_return_value dbms_xs_nsattrlist := new dbms_xs_nsattrlist();
  begin
    if a_ut_vals is null
    then
      goto return_clause;
    end if;
    
    l_return_value.extend(a_ut_vals.count);
    for i in 1 .. a_ut_vals.count
    loop
      l_return_value(i) := new dbms_xs_nsattr( a_ut_vals(i).ns_name, a_ut_vals(i).attribute_name, a_ut_vals(i).attribute_value );
    end loop;
    
    <<return_clause>>
    return l_return_value;
  end;

  function ut_role_to_xs_role( a_ut_vals in ut_principal_list ) return xs$name_list
  as
    l_return_value  xs$name_list := new xs$name_list();
  begin
    if a_ut_vals is null then return null; end if;
  
    for i in 1 .. a_ut_vals.count
    loop
      l_return_value.extend();
      l_return_value( l_return_value.last ) := a_ut_vals(i).principal_name;
    end loop;
    
    return l_return_value;
  end;

end;
/
