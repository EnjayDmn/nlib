--
-- $Id: nlib-001.sql,v 1.12 2014-01-31 18:01:03 nils-1327 Exp $ 
--


use %%%MAKEFILE_DATABASE_TARGET%%%;

--
-- An environmental table
--


drop table if exists nlib_environment;
CREATE TABLE nlib_environment(
	id int not null auto_increment,
	reg_key varchar(100) not null,
	reg_value text not null,
	primary key(id)
);

alter table `nlib_environment` AUTO_INCREMENT=1;

insert into nlib_environment values('','version_db','0.01');
insert into nlib_environment (id,reg_key,reg_value) select '', 'salt_master', SHA1(NOW());
select sleep(3);
insert into nlib_environment (id,reg_key,reg_value) select '', 'key_master', SHA1(NOW());
insert into nlib_environment values('', 'key_action', '');


--
-- An example table object that corresponds with the basic TableObject class.
-- Table object tables all have the prefix nlib_to_* followed by the name of 
-- the table.
--
drop table if exists nlib_to_tableobject;
CREATE TABLE nlib_to_tableobject(
	id int not null auto_increment,
	x int not null,
	primary key(id)
);

alter table `nlib_to_tableobject` AUTO_INCREMENT=1;

insert into nlib_to_tableobject values('','11');
insert into nlib_to_tableobject values('','23');
insert into nlib_to_tableobject values('','42');


-- 
-- The table for the session object
-- Depending on the session type the user reference might be 0.
--
drop table if exists nlib_session;
CREATE TABLE nlib_session(
	id int not null auto_increment,
	id_user int not null,
	sess_flavour int not null,
	sess_offset DATETIME not null,
	sess_change DATETIME not null,
	source_ip varchar(100) not null,
	sess_ticket varchar(100) not null,
	sess_key varchar(100) not null,
	primary key(id)
);

alter table `nlib_session` AUTO_INCREMENT=1;

--
-- A default user account table in case of
-- a personalized session.
--
drop table if exists nlib_to_user;
CREATE TABLE nlib_to_user(
	id int not null auto_increment,
	uname varchar(100) not null,
	passenc varchar(100) not null,
	passenc_master varchar(100) not null,
	primary key(id)
);

alter table `nlib_to_user` AUTO_INCREMENT=1;

-- secret
insert into nlib_to_user values('','nlib','$1$gZj4yyE.$t2ouo6Q33IKIbpH9lDJrI1',''); 

drop table if exists map_flow_request_followup;
CREATE TABLE map_flow_request_followup(
	id int not null auto_increment,
	id_flow_type int not null,
	id_request int not null,
	id_followup int not null,
	primary key(id)
);

alter table `map_flow_request_followup` AUTO_INCREMENT=1;

drop table if exists nlib_flow_type;
CREATE TABLE nlib_flow_type(
	id int not null auto_increment,
	flowname varchar(100) not null,
	primary key(id)
);

alter table `nlib_flow_type` AUTO_INCREMENT=1;

drop table if exists nlib_flow_instance;
CREATE TABLE nlib_flow_instance(
	id int not null auto_increment,
	id_flow_type int not null,
	primary key(id)
);

alter table `nlib_flow_instance` AUTO_INCREMENT=1;


--
-- The flow status of the current user, which is
-- session-independent
drop table if exists nlib_flow_status;
create table nlib_flow_status(
	id int not null auto_increment,
	id_flow_instance int not null,
	id_request int not null,
	id_user int not null,
	id_session int not null,
	primary key(id)
);
alter table `nlib_flow_status` AUTO_INCREMENT=1;
