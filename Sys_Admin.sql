drop user application_admin;
create user application_admin identified by "PasswordForAppAdmin123";
grant connect, resource to application_admin;
grant create session to application_admin with admin option;
grant create table to application_admin;
alter user application_admin quota unlimited on data;
grant create view, create procedure, create sequence,create trigger to application_admin;

