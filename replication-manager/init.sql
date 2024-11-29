CREATE USER 'repuser'@'%' IDENTIFIED BY 'REPUSER_PASSWORD'; 
GRANT REPLICATION SLAVE on *.* to 'repuser'@'%'; 

CREATE USER 'manager'@'%' IDENTIFIED BY 'MANAGER_PASSWORD';   
GRANT select,reload,process,super,replication slave,replication client ON *.* to 'manager'@'%';

