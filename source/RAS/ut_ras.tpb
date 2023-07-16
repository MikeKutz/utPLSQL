create or replace type body ut_ras
as
  constructor function ut_ras return self as result
  as
  begin
    ras_sessions := new ut_ras_session_hash();
    
    return;
  end;
  
  member procedure ad_hoc_attach_session( self in out nocopy ut_ras,  a_session_info   in out ut_ras_session_info )
  as
    l_adjusted_session  ut_ras_session_info;
    
    l_ns_attribs  ut_ns_attrib_list;
    l_n int;
  begin
    if a_session_info is null then return; end if;
    
    self.get_or_create_session( a_session_info );

    l_adjusted_session := a_session_info;
    if l_adjusted_session.ns_attrib_list is null
    then
      l_adjusted_session.ns_attrib_list := new ut_ns_attrib_list();
    end if;
    
    -- copy over CONTEXT attributes
    <<utils_cp_context>>
    begin
      l_ns_attribs := ut_ras_utils.get_context_values();

      -- copy over parameter attributes
      l_n := l_ns_attribs.first;
      while( l_n is not null )
      loop
        l_adjusted_session.ns_attrib_list.extend();
        l_adjusted_session.ns_attrib_list( l_adjusted_session.ns_attrib_list.last ) := l_ns_attribs( l_n );
        
        l_n := l_ns_attribs.next( l_n );
      end loop;
    end;
    
    -- l.enable_roles := principal_minus_principal( a.enabled_roles, a.disabled_roles );
    -- l.external_roles := principal_minus_principal( a.external_roles, a.disabled_roles );

    ut_ras_utils.ad_hoc_attach( l_adjusted_session );
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
    l_principal_user.is_external := ut_utils.boolean_to_int( true );
    self.attach_session( l_principal_user );
  end;

  member procedure detach_session( a_abort in boolean default false)
  as
  begin
    if ut_ras_utils.is_ras_session
    then
      dbms_xs_sessions.save_session;
    end if;
    ut_ras_utils.detach_session( a_abort );
  end;
  
  member procedure destroy_all_sessions( self in out nocopy ut_ras )
  as
    l_users      ut_principal_list := new ut_principal_list();
    l_sessionid  raw(32);
    
  begin
    self.detach_session;

    l_users := self.ras_sessions.get_all_users();
    
    for i in 1 .. l_users.count
    loop
      l_sessionid := ras_sessions.get_sessionid( l_users(i).to_string() );
      if l_sessionid is not null
      then
        dbms_xs_sessions.destroy_session( l_sessionid );
      end if;
    end loop;
    self.ras_sessions := new ut_ras_session_hash();
  end;

  member procedure get_or_create_session( self in out nocopy ut_ras, a_session_info in out nocopy ut_ras_session_info )
  as
    no_session       exception;
    l_ns_attriblist  dbms_xs_nsattrlist;
  begin
    if a_session_info is null then return; end if;
    if a_session_info.principal.principal_name is null then return; end if;
    
    if self.ras_sessions.user_exists( a_session_info.principal.to_string() )
    then
      a_session_info.sessionid := self.ras_sessions.get_sessionid( a_session_info.principal.to_string() );

      if a_session_info.sessionid is null
      then
        raise no_session;
      end if;
    else
      raise no_session;
    end if;
  exception
    when no_session then
      dbms_xs_sessions.create_session( username    => a_session_info.principal.principal_name
                                     , sessionid   => a_session_info.sessionid
                                     , is_external => case when a_session_info.principal.is_external = 1 then true else false end
                                     , namespaces  => l_ns_attriblist );
      ras_sessions.set_user( a_session_info.principal.to_string(), a_session_info.sessionid );
  end;

end;
/

