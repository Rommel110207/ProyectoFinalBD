use master;
go

if db_id(N'EvaluacionRRHHBD') is not null
begin
    alter database EvaluacionRRHHBD set single_user with rollback immediate;
    drop database EvaluacionRRHHBD;
end
go

create database EvaluacionRRHHBD;
go

use EvaluacionRRHHBD;
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
    constraint Ck_rango_puntuacion check (Puntuacion_final is null or Puntuacion_final between 0 and 100)
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


-- FASE 2: DML (Población de Datos y Operaciones)

insert into rrhh.Departamento (Nombre_departamento) values 
    (N'Dirección General'), 
    (N'Tecnología'), 
    (N'Ventas'), 
    (N'Marketing (Para borrar)');

insert into rrhh.Puesto (Nombre_puesto) values 
    (N'Gerente General'), 
    (N'Desarrollador Backend'), 
    (N'Ejecutivo de Ventas'), 
    (N'Pasante (Para borrar)');

insert into rrhh.Competencia_objetivo (Nombre, Escala_calificacion) values 
    (N'Liderazgo', 5), 
    (N'Trabajo en Equipo', 5), 
    (N'Resolución de Problemas', 10), 
    (N'Obsolescencia', 5);

insert into rrhh.Ciclo_evaluacion (Nombre_ciclo, Fecha_inicio, Fecha_fin) values 
    (N'Anual 2024', '2024-01-01', '2024-12-31'),
    (N'Semestral 2025-1', '2025-01-01', '2025-06-30'),
    (N'Semestral 2025-2', '2025-07-01', '2025-12-31'),
    (N'Ciclo Cancelado', '2026-01-01', '2026-12-31');

insert into rrhh.Plantilla_evaluacion (Nombre_plantilla) values 
    (N'Plantilla Ejecutiva'), 
    (N'Plantilla Técnica'), 
    (N'Plantilla Comercial'), 
    (N'Plantilla Borrador');

insert into rrhh.Empleado (Nombres, Apellidos, Id_departamento, Id_puesto, Id_jefe) values 
    (N'Carlos', N'Slim', 1, 1, null), 
    (N'Ada', N'Lovelace', 2, 2, 1),   
    (N'Steve', N'Jobs', 3, 3, 1),     
    (N'Juan', N'Pérez', 3, 3, 3);

insert into rrhh.Evaluacion (Id_empleado, Id_ciclo, Id_plantilla, Estado, Puntuacion_final) values 
    (2, 1, 2, N'Completada', 95.50),
    (3, 1, 3, N'Completada', 88.00),
    (2, 2, 2, N'En Progreso', null),
    (1, 1, 1, N'Pendiente', null);

insert into rrhh.Detalle_evaluacion (Id_evaluacion, Id_competencia, Calificacion, Comentarios_jefe) values
    (1, 2, 5, N'Excelente colaboración con el equipo de QA.'),
    (1, 3, 9, N'Resolvió el bug de producción eficientemente.'),
    (2, 1, 4, N'Buen manejo de la cartera de clientes.'),
    (2, 2, 4, N'Registro temporal para borrar.');

update rrhh.Departamento 
set Nombre_departamento = N'Tecnología e Innovación' 
where Id_departamento = 2;

update rrhh.Puesto 
set Nombre_puesto = N'Ingeniero Backend' 
where Id_puesto = 2;

update rrhh.Competencia_objetivo 
set Estado = N'Inactivo' 
where Id_competencia = 3;

update rrhh.Ciclo_evaluacion 
set Nombre_ciclo = N'Evaluación Anual 2024' 
where Id_ciclo = 1;

update rrhh.Plantilla_evaluacion 
set Nombre_plantilla = N'Plantilla TI' 
where Id_plantilla = 2;

update rrhh.Empleado 
set Nombres = N'Carlos A.' 
where Id_empleado = 1;

update rrhh.Evaluacion 
set Estado = N'Completada', Puntuacion_final = 92.00 
where Id_evaluacion = 3;

update rrhh.Detalle_evaluacion 
set Calificacion = 5 
where Id_detalle = 3;

delete from rrhh.Detalle_evaluacion where Id_detalle = 4;
delete from rrhh.Evaluacion where Id_evaluacion = 4;
delete from rrhh.Empleado where Id_empleado = 4;
delete from rrhh.Plantilla_evaluacion where Id_plantilla = 4;
delete from rrhh.Ciclo_evaluacion where Id_ciclo = 4;
delete from rrhh.Competencia_objetivo where Id_competencia = 4;

update rrhh.Puesto 
set Deleted_at = sysdatetime() 
where Id_puesto = 4;

update rrhh.Departamento 
set Deleted_at = sysdatetime() 
where Id_departamento = 4;
go


-- FASE 3: DQL (Vistas)

create view rrhh.Vw_Ranking_Desempeno as
select
    e.Id_empleado,
    e.Nombres + N' ' + e.Apellidos as Empleado,
    d.Nombre_departamento as Departamento,
    p.Nombre_puesto as Puesto,
    c.Nombre_ciclo as Ciclo,
    ev.Puntuacion_final,
    ev.Estado
from rrhh.Evaluacion ev
inner join rrhh.Empleado e on ev.Id_empleado = e.Id_empleado
inner join rrhh.Departamento d on e.Id_departamento = d.Id_departamento
inner join rrhh.Puesto p on e.Id_puesto = p.Id_puesto
inner join rrhh.Ciclo_evaluacion c on ev.Id_ciclo = c.Id_ciclo;
go

-- Nuevos departamentos
insert into rrhh.Departamento (Nombre_departamento) values
    (N'Recursos Humanos'),
    (N'Finanzas'),
    (N'Soporte Técnico'),
    (N'Calidad');

-- Nuevos puestos
insert into rrhh.Puesto (Nombre_puesto) values
    (N'Analista de Recursos Humanos'),
    (N'Contador General'),
    (N'Técnico de Soporte'),
    (N'QA Tester'),
    (N'Supervisor de Ventas'),
    (N'Coordinador de Proyectos');

-- Nuevas competencias
insert into rrhh.Competencia_objetivo (Nombre, Escala_calificacion, Estado) values
    (N'Comunicación efectiva', 5, N'Activo'),
    (N'Puntualidad', 5, N'Activo'),
    (N'Productividad', 10, N'Activo'),
    (N'Adaptabilidad', 5, N'Activo'),
    (N'Atención al cliente', 5, N'Activo'),
    (N'Gestión del tiempo', 5, N'Activo'),
    (N'Calidad del trabajo', 10, N'Activo');

-- Nuevos ciclos
insert into rrhh.Ciclo_evaluacion (Nombre_ciclo, Fecha_inicio, Fecha_fin) values
    (N'Evaluación Anual 2025', '2025-01-01', '2025-12-31'),
    (N'Evaluación Semestral 2026-1', '2026-01-01', '2026-06-30');

-- Nuevas plantillas
insert into rrhh.Plantilla_evaluacion (Nombre_plantilla) values
    (N'Plantilla Administrativa'),
    (N'Plantilla Servicio al Cliente'),
    (N'Plantilla Supervisión');

-- Nuevos empleados
insert into rrhh.Empleado (Nombres, Apellidos, Id_departamento, Id_puesto, Id_jefe) values
    (N'María', N'González', 5, 5, 1),
    (N'Luis', N'Martínez', 6, 6, 1),
    (N'Fernanda', N'Castillo', 7, 7, 2),
    (N'Roberto', N'Mendoza', 8, 8, 2),
    (N'Camila', N'Rivera', 3, 9, 3),
    (N'Andrés', N'Flores', 2, 10, 2),
    (N'Sofía', N'Ramírez', 5, 5, 5),
    (N'Diego', N'Torres', 7, 7, 7),
    (N'Valeria', N'Navarro', 8, 8, 8),
    (N'Marco', N'Herrera', 3, 3, 9);

-- Nuevas evaluaciones
insert into rrhh.Evaluacion (Id_empleado, Id_ciclo, Id_plantilla, Estado, Puntuacion_final) values
    (5, 5, 5, N'Completada', 91.00),
    (6, 5, 5, N'Completada', 84.50),
    (7, 5, 6, N'Completada', 76.00),
    (8, 5, 2, N'Completada', 89.75),
    (9, 5, 7, N'Completada', 93.25),
    (10, 5, 2, N'En Progreso', null),
    (11, 6, 5, N'Pendiente', null),
    (12, 6, 6, N'En Progreso', null),
    (13, 6, 2, N'Completada', 97.00),
    (14, 6, 7, N'Completada', 86.50);

-- Nuevos detalles de evaluación
insert into rrhh.Detalle_evaluacion (Id_evaluacion, Id_competencia, Calificacion, Comentarios_jefe) values
    (5, 5, 5, N'Mantiene buena comunicación con el equipo.'),
    (5, 6, 5, N'Cumple con sus horarios y entregas.'),
    (5, 10, 4, N'Organiza bien sus tareas.'),

    (6, 5, 4, N'Se comunica bien con sus compañeros.'),
    (6, 7, 8, N'Muestra buen nivel de productividad.'),
    (6, 11, 8, N'Entrega trabajos con buena calidad.'),

    (7, 9, 4, N'Brinda buena atención a los usuarios.'),
    (7, 6, 3, N'Debe mejorar su puntualidad.'),
    (7, 10, 3, N'Necesita organizar mejor sus tiempos.'),

    (8, 3, 9, N'Resuelve problemas técnicos con rapidez.'),
    (8, 11, 9, N'Presenta entregas de buena calidad.'),
    (8, 8, 4, N'Se adapta bien a cambios del equipo.'),

    (9, 1, 5, N'Muestra liderazgo con su equipo de ventas.'),
    (9, 2, 5, N'Trabaja muy bien en equipo.'),
    (9, 7, 9, N'Mantiene alto rendimiento comercial.'),

    (13, 3, 10, N'Resuelve incidencias críticas de manera eficiente.'),
    (13, 11, 10, N'Su trabajo tiene excelente calidad.'),
    (13, 8, 5, N'Se adapta rápido a nuevas herramientas.'),

    (14, 1, 4, N'Tiene buen manejo del equipo.'),
    (14, 5, 4, N'Se comunica correctamente.'),
    (14, 10, 4, N'Administra adecuadamente sus tareas.');
go
