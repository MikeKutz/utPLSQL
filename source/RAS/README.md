Using utPLSQL with Real Application Security (RAS)
===

The unit testing framework, `utPLSQL`, has been modified to work easily with Real Application Security (RAS) sessions.

These modification allows the test builder to configur the RAS session via Annotations.

Those Annotations allow one to:
- Set the RAS User for the `--%test`
- Enable/Disable Dynamic Application Roles for the RAS Session of the user
- Enabling & Setting of Session Context values (`xs_sys_context`)

After all tests have finished, the `utPLSQL` engine auto destroys all RAS Sessions that were created. (`dba_xs_sessions`)

## RAS Annotations

Annotation | Description
----|----
xsuser | Runs a `--%test` as a specific internal RAS user. (limit 1. not compatible with `--%xsextuser`)
xsextuser | Runs a `--%test` as a specific external RAS user. (limit 1. not compatible with `--%xsuser`)
xsrole | Enables Internal Dynamic Role(s).  Preserved across calls.
xsextrole | Enable External Dynamic Role(s).  Preserved across calls.
xsnsattr | Sets Namespace-Attribute-Value.  Only the first one is preserved across calls
xsdsomething | Disables Dynamic Role(s) {TODO}

### XSUSER syntax

`--%xsuser( name )`, `--%xsextuser( name )`, `--%xsuser( name, dbh )`, `--%xsextuser( name, dbh )`

This annotation determines which RAS User (and session) is used while running a `--%test`.  Only `--%test` is affected.  Do to the stateless nature of RAS Sessions, all `--%test` are implicitly `autonomous_transaction` that calls `commit` at the end.

Any modifications to the session context (`xs_sys_context`) *should* carry over to the next `--%test`.

*note* the settings set by the `--%xsnsattr` annotation does not do this)

- only one per `--%test` can exist
- *name* is the name of the user that the framwork will "sudo" to for the `--%test`
- *db* is an optional unique session identifier (not fully tested)

*note* No known way to drop an external user ( `dba_xs_external_principals` )

### XSROLE syntax

`--%xsrole( role_1 [, role_2 ... ])` or `--%xsextrole( role_1 [, role_2 ... ])`

- multiple entries can exist for the same `--%test`
- one role can be named in the annotation. Multiple roles can be named in the same annotation (CSV style)
- a test can have both `--%xsrole` and `--%xsextrole`
- a test can have multiple role Annotations
- active roles are listed in `v$xs_session_roles`

### XSNSATTR syntax

`--%xsnsattr( ns_name, attr_name, attr_val )`

- both *attr_name* and *attr_val* are optional
- a test can have (and should have) multiple Annotations.  1 per attribute being set
- a template must exist before running (`xs_namespace.create_template`)
- a Namespace must exist in the session before the Test can set a value.
  - use the `--%xsnsattr` annotation
  - create from a template (`dbms_xs_sessions.create_namespace`)
- unlike `context`, a Namespace can be modified by the end-user unless protected by an ACL
- only the values set by the RAS Session is preserved across multiple `--%test` (per *user,dbh*)
- `xs_sys_context` is bugged. Beware of case when using it.


## Developer Notes

- Tester account needs the `XS_SESSION_ADMIN` database role
- Test Package needs to be Invoker's Rights. (`authid current_user`)
- Test User ( `--%xsuser` ) needs the ability to execute the package on its own ( `grant execute on pkg_name to public`)
- Test Suite needs to have manual transaction control. ( `--%rollback(manual)` )
- comparisons (eg `ut.expect().to_equal()` ) are not yet reported correctly.


