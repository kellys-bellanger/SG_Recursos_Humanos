use master
go
if exists(select * from sys.databases where name like 'SG_Recursos_Humanos')
begin
	drop database SG_Recursos_Humanos
end
go
Create database SG_Recursos_Humanos
go

use SG_Recursos_Humanos
go