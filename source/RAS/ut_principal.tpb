create or replace type body ut_principal
as
  constructor function ut_principal return self as result
  as
  begin
    self.is_external := 0;
    
    return;
  end;
  
  constructor function ut_principal( username in varchar2 ) return self as result
  as
  begin
    self.parse( username );
    
    self.is_external := 0;
    
    return;
  end;
  
  member procedure parse( self in out nocopy ut_principal, username in varchar2 )
  as
  begin
    if instr(username,':') > 0
    then
      self.principal_name := substr( username, 1, instr(username, ':') - 1);
      self.unique_identifier := substr( username, instr(username, ':' + 1) );
    else
      self.principal_name := username;
      self.unique_identifier := 'Default';
    end if;

  end;
  
  member function to_string return varchar2
  as
  begin
    if self.principal_name is null
    then
      return null;
    end if;
    
    if self.unique_identifier = 'Default'
    then
      return self.principal_name;
    else
      return self.principal_name || ':' || self.unique_identifier;
    end if;
  end;
end;
/

