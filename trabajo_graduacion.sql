create database trabajos_graduacion


create table sede
(
cod_sede int
constraint SEDE_COD_SEDE_PK primary key (cod_sede)
constraint sede_cod_sede_ck check 
(cod_sede like '[0][1-8]'),

nombre_sede varchar(50)
constraint sede_nombre_sede_ck check
(nombre_sede in ('Campus Victor Levi Sasso','Centro Regional de Colón','Centro Regional de Panamá Oeste',
'Centro Regional de Coclé', 'Centro Regional de Azuero','Centro Regional de Veraguas','Centro Regional de Chiriquí',
'Centro Regional de Bocas del Toro')),

ubicacion varchar(25) 
constraint sede_ubicacion_ck check
(ubicacion in ('Panamá','colón','Panamá Oeste', 'Coclé','Veraguas','Chiriquí','Bocas del Toro'))

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
	cod_depto int identity
		constraint DEPARTAMENTO_COD_DEPTO_PK primary key(cod_depto),

	nombre_depto varchar(40),

	cod_profesor_jefe int unique 
	
	constraint DEPARTAMENTO_COD_PROFESOR_JEFE_FK foreign key
	(cod_profesor_jefe) references profesor(cod_profesor)

	constraint DEPARTAMENTO_COD_PROFESOR_JEFE_CK check
	(cod_profesor_jefe = (select cod_profesor from profesor where tipo_prof = 'Jefe'))

)


alter table profesor
	add constraint PROFESOR_COD_DEPTO_FK 
		foreign key (cod_depto)
			references departamento(cod_depto)



create table proyecto
(
	cod_proyecto varchar(15) 
		constraint PROYECTO_COD_PROYECTO_PK primary key(cod_proyecto),
	tipo_proyecto char(2),
	titulo_proyecto varchar(50) unique,
	fecha_entrega date 
		constraint proyecto_fecha_entrega_ck 
			check (fecha_entrega <= getdate()),
	fecha_verificacion date 
		constraint proyecto_fecha_verificacion_ck 
			check (fecha_verificacion <= getdate() and fecha_verificacion <= fecha_entrega ) ,
	fecha_evaluacion date 
		constraint proyecto_fecha_evaluacion_ck 
			check (fecha_evaluacion <= getdate() and fecha_evaluacion <= fecha_verificacion ),
	fecha_aprobacion date 
	constraint proyecto_fecha_aprobacion_ck 
		check (fecha_aprobacion <= getdate() and fecha_aprobacion <= fecha_evaluacion ),

	fecha_sustentacion date 
		constraint proyecto_fecha_sustentacion_ck 
			check (fecha_sustentacion <= getdate() and fecha_sustentacion <= fecha_aprobacion ),
	cod_profesor int 
		constraint PROYECTO_COD_PROFESOR_FK 
			foreign key (cod_profesor) 
				references profesor(cod_profesor),

)



create table Evaluacion (
    cod_proyecto varchar(15)
		constraint Evaluacion_cod_proyecto_fk 
			foreign key (cod_proyecto)
				references Proyecto(cod_proyecto),
    fecha_evaluacion date,
    Evaluacion varchar,

		Constraint EVALUACION_CODPROYECTO_FECHAEV_PK
			Primary key(cod_proyecto, Fecha_evaluacion)
)

create table Carrera (
    cod_carrera int identity
	constraint carrera_cod_carrera_pk primary key ,
    nombre_carrera varchar,
    Cod_depto int 
		constraint Carrera_cod_depto_FK 
			foreign key(cod_depto)
				references Departamento(cod_depto)
)

create table Estudiante(
	ced_estudiante int
		constraint Estudiante_ced_estudiante_pk primary key
		 constraint Estudiante_ced_estudiante_ck check
		 (ced_estudiante like '[0][1-9][-][0-9][0-9][0-9][0-9][-][0-9][0-9][0-9][0-9][0-9]'
		or 
			ced_estudiante like '[1][0-3][-][0-9][0-9][0-9][0-9][-][0-9][0-9][0-9][0-9][0-9]')
			/* falta lo de la cedula de los extranjeros */,
    pri_nom varchar(25),
    seg_nom varchar(25),
    pri_apellido varchar(25),
    seg_apellido varchar(25),
    año_cursa DATE,
    semestre int,
    indice float,

    cod_proyecto varchar(15)
		constraint Estudiante_cod_proyecto_fk 
			foreign key (cod_proyecto)
				references Proyecto (cod_proyecto),
    cod_carrera int
		constraint Estudiante_cod_carrera_fk foreign key 
			references Carrera (cod_carrera),
    cod_sede int
		constraint Estudiante_cod_sede_fk foreign key 
		 references Sede(cod_sede)
)

create table proyecto_profesor_sustenta
(
	cod_profesor int
	constraint proyecto_profesor_sustenta_cod_profesor_FK foreign key
	(cod_profesor) references profesor(cod_profesor),

	cod_proyecto int 
	constraint proyecto_profesor_sustenta_cod_proyecto_FK foreign key
	(cod_profesor) references profesor (cod_profesor),

	ced_estudiante int 
		constraint proyecto_profesor_sustenta_ced_estudiante_FK 
		foreign key(ced_estudiante) 
			references estudiante(ced_estudiante)
)

create sequence Numero_Proyecto
	start with 1000
	Increment BY 1

create TRIGGER Inserta_Proyecto
ON proyecto
INSTEAD OF INSERT
AS

declare @tipo_proy char(2),
		@titulo_proy varchar(50),
		@cod_profesor int,
		@fecha_entrega date,
		@fecha_verificacion date,
		@fecha_evaluacion date,
		@fecha_aprobacion date,
		@fecha_sustentacion date,
		@cod_proyecto varchar(15),
		@annio int = year(getdate()),
		@secuencia int

	select @tipo_proy = inserted.tipo_proyecto,
		   @titulo_proy = inserted.titulo_proyecto,
		   @fecha_entrega = inserted.fecha_entrega,
		   @fecha_verificacion = inserted.fecha_verificacion,
		   @fecha_evaluacion = inserted.fecha_evaluacion,
		   @fecha_aprobacion = inserted.fecha_aprobacion,
		   @fecha_sustentacion = inserted.fecha_sustentacion,
		   @cod_profesor = inserted.cod_profesor
		from inserted

	set @secuencia = NEXT VALUE FOR Numero_Proyecto
	set @cod_proyecto = CONCAT(@tipo_proy,'-',@annio,'-',@secuencia)

	insert into proyecto (cod_proyecto,tipo_proyecto,titulo_proyecto,fecha_entrega,fecha_verificacion,fecha_evaluacion,fecha_aprobacion,fecha_sustentacion,cod_profesor)
		values (@cod_proyecto, @tipo_proy,@titulo_proy,@fecha_entrega,@fecha_verificacion,@fecha_evaluacion,@fecha_aprobacion,@fecha_sustentacion,@cod_profesor)         