
--
-- $Id: requests.sql,v 1.4 2013-12-31 00:47:23 nils-1327 Exp $
--

use %%%MAKEFILE_DATABASE_TARGET%%%;

update nlib_environment set reg_value = 'aa051c43f4a7a95f0d2948a14e59416e92202d3d' where reg_key = 'key_action';

drop table if exists nlib_requests;
CREATE TABLE nlib_requests(
	id int not null auto_increment,
	req_type int not null,
	req_name varchar(100) not null,
	req_value varchar(100) not null,
	req_json_in text not null,
	req_json_out text not null,
	req_desc text not null,
	primary key(id)
);

alter table `nlib_requests` AUTO_INCREMENT=1;
INSERT INTO nlib_requests VALUES('','0','ANY','1Lyz0N+sOCh3X82dj2LkPDTXH8o','{}','{"status":""}','Any status'); INSERT INTO nlib_requests VALUES('','1','updateWidgets','84bPz7jm5undBKLcdrndzbGFcBU','{}','{"status":""}','A request for updating all widget states'); INSERT INTO nlib_requests VALUES('','1','logout','uv5v1OJXd+bOSKW4CZMQZUMZJrs','{}','{"status":""}','A logout request'); INSERT INTO nlib_requests VALUES('','1','login','Fk7GalYOxFbGrKSPahvK4detyrQ','{"username":"","password":""}','{"status":""}','A login request');
