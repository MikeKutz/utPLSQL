declare
    l_ns_attrib_vals  xs$ns_attribute_list := new xs$ns_attribute_list();
    l_attribs         ut_varchar2_list;
begin
    l_attribs := ut_session_context.list_attributes;
    
    l_ns_attrib_vals.extend( l_attribs.count );
    
    for i in 1 .. l_attribs.count
    loop
        l_ns_attrib_vals(i) := new xs$ns_attribute( l_attribs(i) );
    end loop;
    
    
    xs_namespace.create_template( ut_session_context.get_namespace, attr_list => l_ns_attrib_vals );
end;
/
