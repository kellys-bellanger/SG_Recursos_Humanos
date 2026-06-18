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
create schema Organizacion;
go

create schema Personal;
go

create schema Laboral;
go

create schema Controles;
go

create schema Desempeno;
go

create schema Formacion;
go
create table Organizacion.Departamentos (
    nDepartamentoID int identity(1,1) primary key,
    cNombreDepartamento nvarchar(100) not null unique,
    cDescripcion nvarchar(255),
    cUbicacion nvarchar(150),
    cEstado nvarchar(20) not null,

    created_at datetime default getdate(),
    updated_at datetime,
    deleted_at datetime,

    constraint CK_Departamentos_Estado 
    check (cEstado in ('Activo', 'Inactivo'))
);
go