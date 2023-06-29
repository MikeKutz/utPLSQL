create or replace type body ut_ras
as
  constructor function ut_ras return self as result
  as
  begin
    ras_sessions := new ut_ras_session_hash();
    
    return;
  end;
  
  member procedure ad_hoc_attach_session( a_session_info   in out ut_ras_session_info )
  as
    l_session       ut_ras_session_info;
    l_ns_attriblist dbms_xs_nsattrlist := new dbms_xs_nsattrlist();
    l_at            ut_ns_attrib_list;
    l_n             int;
    l_sessionid     raw(32);
  begin
    -- check input is valid
    if a_session_info.disabled = 1
      or a_session_info.principal is null
    then
      return;
    end if;

    -- copy basic info    
    l_session.principal := a_session_info.principal;
    l_session.sessionid := a_session_info.sessionid;
    l_session.disabled  := 0;

    -- copy over CONTEXT attributes
    l_session.ns_attrib_list := ut_ras_utils.get_context_values();

    -- copy over parameter attributes
    if a_session_info.ns_attrib_list is not null
    then
      l_n := l_session.ns_attrib_list.count;
      l_session.ns_attrib_list.extend(a_session_info.ns_attrib_list.count);
      
      for i in 1 .. a_session_info.ns_attrib_list.count
      loop
        l_session.ns_attrib_list( l_n + i ) := a_session_info.ns_attrib_list(i);
      end loop;
    end if;
    -- build enable minus disable
    -- build external muinus disable
    -- build disable
    
    -- lookup session id
    -- get_or_make_session()
    <<create_session>>
    declare
      no_session exception;
      l_ns_attriblist dbms_xs_nsattrlist := new dbms_xs_nsattrlist();
    begin
      if ras_sessions.user_exists( l_session.principal.to_string() )
      then
        l_session.sessionid := ras_sessions.get_sessionid( l_session.principal.to_string() );
        if l_session.sessionid is null
        then
          raise no_session;
        end if;
      else
        raise no_session;
      end if;
    exception
      when no_session then
        dbms_xs_sessions.create_session( username    => l_session.principal.principal_name
                                       , sessionid   => l_session.sessionid
                                       , is_external => case when l_session.principal.is_external = 1 then true else false end
                                       , namespaces  => ut_ras_utils.ut_attrib_to_xs_attrib( l_session.ns_attrib_list ) );
        ras_sessions.set_user( l_session.principal.to_string(), l_sessionid );
    end;

    -- attach to session
    ut_ras_utils.ad_hoc_attach( a_session_info );
  end;

  member procedure attach_session( user_name             in ut_principal
                                  ,enable_roles          in ut_principal_list default null
                                  ,enable_external_roles in ut_principal_list default null
                                  ,disable_roles         in ut_principal_list default null
                                  ,ns_attributes         in ut_ns_attrib_list default null
                                  )
  as
    l_ns_attriblist dbms_xs_nsattrlist := new dbms_xs_nsattrlist();
    l_at            ut_ns_attrib_list;
    l_n             int;
    l_sessionid     raw(32);
  begin
    -- copy over CONTEXT attributes
    l_at := ut_ras_utils.get_context_values();
    l_ns_attriblist.extend( l_at.count );
    for i in 1 .. l_at.count
    loop
      l_ns_attriblist(i) := new dbms_xs_nsattr( l_at(i).ns_name, l_at(i).attribute_name, l_at(i).attribute_value );
    end loop;

    -- copy over parameter attributes
    if ns_attributes is not null
    then
      l_n := l_ns_attriblist.count;
      l_ns_attriblist.extend(ns_attributes.count);
      for i in 1 .. ns_attributes.count
      loop
        l_ns_attriblist( l_n + i ) := dbms_xs_nsattr( ns_attributes(i).ns_name, ns_attributes( i ).attribute_name, ns_attributes(i).attribute_value);
      end loop;
    end if;
    -- build enable minus disable
    -- build external muinus disable
    -- build disable
    
    -- lookup session id
    <<create_session>>
    declare
      no_session exception;
    begin
      if ras_sessions.user_exists( user_name.to_string )
      then
        l_sessionid := ras_sessions.get_sessionid( user_name.to_string() );
        if l_sessionid is null
        then
          raise no_session;
        end if;
      else
        raise no_session;
      end if;
    exception
      when no_session then
        dbms_xs_sessions.create_session( username    => user_name.principal_name
                                       , sessionid   => l_sessionid
                                       , is_external => case when user_name.is_external = 1 then true else false end
                                       , namespaces  => l_ns_attriblist );
        ras_sessions.set_user( user_name.to_string(), l_sessionid );
    end;

    -- attach to session
    dbms_xs_sessions.attach_session( sessionid => l_sessionid
                                    ,namespaces => l_ns_attriblist );
  end;

  member procedure attach_session( a_username in varchar2 )
  as
  begin
    self.attach_session( new ut_principal( a_username ));
  end;

  member procedure attach_external_session( a_username in varchar2 )
  as
    l_principal_user ut_principal;
  begin
    l_principal_user := new ut_principal( a_username);
    l_principal_user.is_external := 1;
    self.attach_session( l_principal_user );
  end;

  member procedure detach_session( a_abort in boolean default false)
  as
  begin
    ut_ras_utils.detach_session( a_abort );
  end;
  
  member procedure destroy_all_sessions
  as
    l_users      ut_principal_list := new ut_principal_list();
    l_sessionid  raw(32);
  begin
    self.detach_session;
    
    for i in 1 .. l_users.count
    loop
      l_sessionid := ras_sessions.get_sessionid( l_users(i).to_string() );
      if l_sessionid is not null
      then
        dbms_xs_sessions.destroy_session( l_sessionid );
      end if;
    end loop;
  end;
end;
/

