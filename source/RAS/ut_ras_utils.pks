create or replace
package ut_ras_utils
  authid current_user
as
  /* "source of truth" for all RAS functionality */
  
  function is_ras_session return boolean;
  
  procedure ad_hoc_attach( a_session in ut_ras_session_info );
  
  procedure detach_session( a_abort in boolean default false);
  
  function get_context_values return ut_ns_attrib_list;
  
  function ut_attrib_to_xs_attrib( a_ut_vals in ut_ns_attrib_list) return dbms_xs_nsattrlist;
  
  function ut_role_to_xs_role( a_ut_vals in ut_principal_list ) return xs$name_list;

end;
/
