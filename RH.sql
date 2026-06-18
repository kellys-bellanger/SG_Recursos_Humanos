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
create table Organizacion.Cargos (
    nCargoID int identity(1,1) primary key,
    cNombreCargo nvarchar(100) not null unique,
    cDescripcion nvarchar(255),
    nSalarioBase decimal(10,2) not null,
    cNivelCargo nvarchar(50) not null,

    created_at datetime default getdate(),
    updated_at datetime,
    deleted_at datetime,

    constraint CK_Cargos_SalarioBase 
    check (nSalarioBase > 0)
);
go

-- 3. Tabla: Personal.Empleados
create table Personal.Empleados (
    nEmpleadoID int identity(1,1) primary key,
    cCodigoEmpleado nvarchar(10) not null unique,
    cNumeroIdentificacion nvarchar(30) not null unique,
    cNombres nvarchar(100) not null,
    cApellidos nvarchar(100) not null,
    dFechaNacimiento date not null,
    cSexo char(1) not null,
    cTelefono nvarchar(20),
    cCorreoElectronico nvarchar(100) not null unique,
    cDireccion nvarchar(255),
    dFechaContratacion date not null,
    cEstadoLaboral nvarchar(30) default 'Activo',
    
    -- Llaves Foráneas (3FN)
    nDepartamentoID int not null,
    nCargoID int not null,

    created_at datetime default getdate(),
    updated_at datetime,
    deleted_at datetime,

    constraint CK_Empleados_Sexo 
    check (cSexo in ('M', 'F', 'O')),

    constraint CK_Empleados_EstadoLaboral 
    check (cEstadoLaboral in ('Activo', 'Vacaciones', 'Suspendido', 'Retirado')),

    constraint FK_Empleados_Departamentos 
    foreign key (nDepartamentoID) references Organizacion.Departamentos(nDepartamentoID),

    constraint FK_Empleados_Cargos 
    foreign key (nCargoID) references Organizacion.Cargos(nCargoID)
);
go

-- 4. Tabla: Laboral.Contratos
create table Laboral.Contratos (
    nContratoID int identity(1,1) primary key,
    cCodigoContrato nvarchar(10) not null unique,
    cTipoContrato nvarchar(30) not null,
    dFechaInicio date not null,
    dFechaFinalizacion date,
    nSalarioAcordado decimal(10,2) not null,
    cEstadoContrato nvarchar(30) default 'Activo',
    
    -- Relación con Empleado
    nEmpleadoID int not null,

    created_at datetime default getdate(),
    updated_at datetime,
    deleted_at datetime,

    constraint CK_Contratos_Tipo 
    check (cTipoContrato in ('Temporal', 'Permanente', 'Por proyecto')),

    constraint CK_Contratos_Salario 
    check (nSalarioAcordado > 0),

    constraint FK_Contratos_Empleados 
    foreign key (nEmpleadoID) references Personal.Empleados(nEmpleadoID)
);
go

-- 5. Tabla: Controles.Asistencia
create table Controles.Asistencia (
    nAsistenciaID int identity(1,1) primary key,
    dFecha date not null,
    tHoraEntrada time not null,
    tHoraSalida time,
    cEstadoAsistencia nvarchar(20) not null,
    
    -- Relación con Empleado
    nEmpleadoID int not null,

    created_at datetime default getdate(),
    updated_at datetime,
    deleted_at datetime,

    constraint CK_Asistencia_Estado 
    check (cEstadoAsistencia in ('Presente', 'Ausente', 'Permiso', 'Incapacidad')),

    constraint FK_Asistencia_Empleados 
    foreign key (nEmpleadoID) references Personal.Empleados(nEmpleadoID)
);
go
create table Desempeno.Evaluaciones (
    id_evaluacion int identity(1,1) primary key,
    fecha_evaluacion date not null,
    periodo_evaluado varchar(50) not null,
    calificacion_obtenida int not null,
    comentarios varchar(500),

    id_empleado int not null,

    created_at datetime not null default getdate(),
    updated_at datetime,
    deleted_at datetime,

    constraint CK_Evaluaciones_Calificacion
    check (calificacion_obtenida between 1 and 100),

    constraint FK_Evaluaciones_Empleados
    foreign key (id_empleado)
    references Personal.Empleados(nEmpleadoID)
);
go

/* =========================================================
   7. TABLA CAPACITACIONES
   Schema: Formacion
   ========================================================= */

create table Formacion.Capacitaciones (
    id_capacitacion int identity(1,1) primary key,
    codigo_capacitacion varchar(10) not null,
    nombre_capacitacion varchar(150) not null,
    institucion_responsable varchar(150) not null,
    duracion_horas int not null,
    fecha_realizacion date not null,

    created_at datetime not null default getdate(),
    updated_at datetime,
    deleted_at datetime,

    constraint UQ_Capacitaciones_Codigo unique (codigo_capacitacion),

    constraint CK_Capacitaciones_Duracion
    check (duracion_horas > 0)
);
go

/* =========================================================
   8. TABLA INTERMEDIA EMPLEADO_CAPACITACION
   Relación muchos a muchos:
   Un empleado puede tener muchas capacitaciones.
   Una capacitación puede ser recibida por muchos empleados.
   Schema: Formacion
   ========================================================= */

create table Formacion.EmpleadoCapacitacion (
    id_empleado int not null,
    id_capacitacion int not null,
    fecha_participacion date not null,
    resultado_obtenido varchar(50),

    created_at datetime not null default getdate(),
    updated_at datetime,
    deleted_at datetime,

    constraint PK_EmpleadoCapacitacion
    primary key (id_empleado, id_capacitacion),

    constraint FK_EmpleadoCapacitacion_Empleados
    foreign key (id_empleado)
    references Personal.Empleados(nEmpleadoID),

    constraint FK_EmpleadoCapacitacion_Capacitaciones
    foreign key (id_capacitacion)
    references Formacion.Capacitaciones(id_capacitacion)
);
go