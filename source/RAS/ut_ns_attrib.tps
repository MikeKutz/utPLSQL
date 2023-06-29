create or replace type ut_ns_attrib authid current_user as object (
  ns_name         varchar2(128),
  attribute_name  varchar2(128),
  attribute_value varchar2(128),
  constructor function ut_ns_attrib( txt in varchar2) return self as result,
  member procedure parse( txt in varchar2 ),
  member function to_string return varchar2
);
