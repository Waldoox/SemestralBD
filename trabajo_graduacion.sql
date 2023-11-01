create database trabajos_graduacion

use trabajos_graduacion

create table sede
(
	cod_sede int
		constraint SEDE_COD_SEDE_PK primary key (cod_sede),
	nombre_sede varchar(25),
	ubicacion varchar(50)
)

create table empresa
(
	cod_empresa int
		constraint EMPRESA_COD_EMPRESA_PK primary key (cod_empresa),
	nombre_empresa varchar(30)
) 

create table supervisor
(
	cod_supervisor int 
		constraint SUPERVISOR_COD_SUPERVISOR_PK primary key (cod_supervisor),
	nombre_supervisor varchar(30),
	apellido_supervisor varchar(30),
	cod_empresa int
		constraint SUPERVISOR_COD_EMPRESA_FK 
			foreign key (cod_empresa)
				references empresa(cod_empresa)
)

create table practica_profesional
(
	cod_proyecto char(12)
		constraint PRACTICA_PROFESIONAL_COD_PROYECTO_PK 
			primary key (cod_proyecto),
	cod_supervisor int
		constraint PRACTICA_PROFESIONAL_COD_SUPERVISOR_FK
			foreign key (cod_supervisor)
				references supervisor(cod_supervisor)
)

create table profesor
(
	cod_profesor int 
		constraint PROFESOR_COD_PROFESOR_PK primary key(cod_profesor),
	nombre_prof varchar (50),
	apellido_prof varchar(50),
	tipo_prof char(15),
	cod_depto int 
)

create table departamento
(
	cod_depto int 
		constraint DEPARTAMENTO_COD_DEPTO_PK primary key(cod_depto),
	nombre_depto varchar(25),
	cod_profesor_jefe int
		constraint DEPARTAMENTO_COD_PROFESOR_JEFE_FK
			foreign key(cod_profesor_jefe)
				references profesor(cod_profesor)
		constraint DEPARTAMENTO_COD_PROFESOR_JEFE_CK
			check(cod_profesor_jefe = (select cod_profesor from profesor where tipo_prof = 'Jefe'))
)

alter table profesor
	add constraint PROFESOR_COD_DEPTO_FK 
		foreign key (cod_depto)
			references departamento(cod_depto)

create table proyecto
(
	cod_proyecto char(4) identity 
		constraint PROYECTO_COD_PROYECTO_PK primary key(cod_proyecto) ,
	titulo_proyecto varchar(50),
	cod_profesor int
		constraint PROYECTO_COD_PROFESOR_FK 
			foreign key (cod_profesor)
				references profesor(cod_profesor),
	fecha_entrega date,
	fecha_verificacion date,
	fecha_evaluacion date,
	fecha_aprobacion date,
	fecha_sustentacion date
)

create table proyecto_profesor_sustenta
(
	cod_profesor
	cod_proyecto
	ced_estudiante
)

create table Evaluacion (
    cod_proyecto char(12)
		constraint Evaluacion_cod_proyecto_fk foreign key
			references Proyecto(cod_proyecto),
    fecha_evaluacion date 
		constraint Evaluacion_fecha_evaluacion_fk foreign key 
			references Proyecto (fecha_evaluacion),
    Evaluacion varchar,
	Primary key(cod_proyecto, Fecha_evaluacion)
)

create table Carrera (
    cod_carrera int ,
    nombre_carrera varchar,
    Cod_depto int 
		constraint Carrera_cod_depto_FK foreign key 
			references Departamento(cod_depto)
    primary key (cod_carrera, cod_depto)
)

create table Estudiante(
	ced_estudiante int
		constraint Estudiante_ced_estudiante_pk primary key
		 constraint Estudiante_ced_estudiante_ck check
		 (ced_estudiante like '[0][1-9][-][0-9][0-9][0-9][0-9][-][0-9][0-9][0-9][0-9][0-9]'
		or 
			ced_estudiante like '[1][0-3][-][0-9][0-9][0-9][0-9][-][0-9][0-9][0-9][0-9][0-9]'),
    pri_nom varchar,
    seg_nom varchar,
    pri_apellido varchar,
    seg_apellido varchar,
    año_cursa int,
    semestre int,
    indice float,

    cod_proyecto char(12)
		constraint Estudiante_cod_proyecto_fk foreign key 
			references Proyecto (cod_proyecto),
    cod_carrera int
		constraint Estudiante_cod_carrera_fk foreign key 
			references Carrera (cod_carrera),
    cod_sede int
		constraint Estudiante_cod_sede_fk foreign key 
		 references Sede(cod_sede)
)

