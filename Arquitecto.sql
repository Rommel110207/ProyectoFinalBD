/* ==========================================================================
   ARCHIVO:       01_DDL_Estructura.sql
   AUTOR:         [Rommel Muñoz]
   PROPÓSITO:     Creación de BD, Esquemas y Estructura de Tablas (DDL)
   ========================================================================== */

use master;
go

if db_id(N'Bd_evaluacion_desempeno') is not null
begin
    alter database Bd_evaluacion_desempeno set single_user with rollback immediate;
    drop database Bd_evaluacion_desempeno;
end
go

create database Bd_evaluacion_desempeno;
go

use Bd_evaluacion_desempeno;
go

create schema rrhh;
go

create table rrhh.Departamento (
    Id_departamento     int identity(1,1) primary key,
    Nombre_departamento nvarchar(100) not null unique,
    Created_at          datetime2 default sysdatetime(),
    Deleted_at          datetime2 null
);
go

create table rrhh.Puesto (
    Id_puesto           int identity(1,1) primary key,
    Nombre_puesto       nvarchar(100) not null,
    Created_at          datetime2 default sysdatetime(),
    Deleted_at          datetime2 null
);
go

create table rrhh.Competencia_objetivo (
    Id_competencia      int identity(1,1) primary key,
    Nombre              nvarchar(100) not null unique,
    Escala_calificacion int not null default 5,
    Estado              nvarchar(15) not null default N'Activo',
    constraint Ck_escala_positiva check (Escala_calificacion > 0),
    constraint Ck_estado_competencia check (Estado in (N'Activo', N'Inactivo'))
);
go

create table rrhh.Ciclo_evaluacion (
    Id_ciclo            int identity(1,1) primary key,
    Nombre_ciclo        nvarchar(100) not null,
    Fecha_inicio        date not null,
    Fecha_fin           date not null,
    constraint Ck_fechas_ciclo check (Fecha_fin > Fecha_inicio)
);
go

create table rrhh.Plantilla_evaluacion (
    Id_plantilla        int identity(1,1) primary key,
    Nombre_plantilla    nvarchar(100) not null
);
go

create table rrhh.Empleado (
    Id_empleado         int identity(1,1) primary key,
    Nombres             nvarchar(75) not null,
    Apellidos           nvarchar(75) not null,
    Id_departamento     int not null,
    Id_puesto           int not null,
    Id_jefe             int null, 
    Created_at          datetime2 default sysdatetime(),
    Deleted_at          datetime2 null,
    constraint Fk_empleado_departamento foreign key (Id_departamento) references rrhh.Departamento(Id_departamento),
    constraint Fk_empleado_puesto foreign key (Id_puesto) references rrhh.Puesto(Id_puesto),
    constraint Fk_empleado_jefe foreign key (Id_jefe) references rrhh.Empleado(Id_empleado)
);
go

create table rrhh.Evaluacion (
    Id_evaluacion       int identity(1,1) primary key,
    Id_empleado         int not null,
    Id_ciclo            int not null,
    Id_plantilla        int not null,
    Estado              nvarchar(20) not null default N'Pendiente',
    Puntuacion_final    decimal(5,2) null,
    constraint Fk_evaluacion_empleado foreign key (Id_empleado) references rrhh.Empleado(Id_empleado),
    constraint Fk_evaluacion_ciclo foreign key (Id_ciclo) references rrhh.Ciclo_evaluacion(Id_ciclo),
    constraint Fk_evaluacion_plantilla foreign key (Id_plantilla) references rrhh.Plantilla_evaluacion(Id_plantilla),
    constraint Ck_estado_evaluacion check (Estado in (N'Pendiente', N'En Progreso', N'Completada')),
    constraint Ck_rango_puntuacion check (Puntuacion_final between 0 and 100)
);
go

create table rrhh.Detalle_evaluacion (
    Id_detalle          int identity(1,1) primary key,
    Id_evaluacion       int not null,
    Id_competencia      int not null,
    Calificacion        int null,
    Comentarios_jefe    nvarchar(500) null,
    constraint Fk_detalle_eval_cabecera foreign key (Id_evaluacion) references rrhh.Evaluacion(Id_evaluacion),
    constraint Fk_detalle_eval_competencia foreign key (Id_competencia) references rrhh.Competencia_objetivo(Id_competencia)
);
go