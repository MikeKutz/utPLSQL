create or replace type body ut_ns_attrib
as
  constructor function ut_ns_attrib( txt in varchar2) return self as result
  as
  begin
    self.parse( txt );
    
    return;
  end;
  
  member procedure parse( txt in varchar2 )
  as
  begin
    if txt is null
    then
      raise no_data_found;
    end if;
    
    if instr(txt,':', 1, 2) > 0
    then
      self.ns_name         := substr(txt,1,instr(txt,':') - 1);
      self.attribute_name  := substr( txt, instr(txt,':') + 1, instr(txt,':',1,2) - instr(txt,':') );
      self.attribute_value := substr(txt, instr(txt,':',1,2) + 1);
    elsif instr(txt, ':' ) > 0
    then
      self.ns_name         := substr(txt,1,instr(txt,':') - 1);
      self.attribute_name  := substr(txt, instr(txt,':',1,2) + 1);
      self.attribute_value := null;
    else
      self.ns_name         := txt;
      self.attribute_name  := null;
      self.attribute_value := null;
    end if;
  end;
  
  member function to_string return varchar2
  as
  begin
    if self.attribute_name is null
    then
      return self.ns_name;
    else
      return self.ns_name || ':' || self.attribute_name || '.' || self.attribute_value;
    end if;
  end;
end;
/
