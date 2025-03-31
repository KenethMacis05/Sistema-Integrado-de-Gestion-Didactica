------------------------------------------------CREACION DE LA BASE DE DATOS Y TABLAS------------------------------------------------
USE master
GO
IF NOT EXISTS(SELECT name FROM master.dbo.sysdatabases WHERE NAME = 'SISTEMA_DE_GESTION_DIDACTICA')
CREATE DATABASE SISTEMA_DE_GESTION_DIDACTICA
GO

USE SISTEMA_DE_GESTION_DIDACTICA
GO

-- (1) TABLA ROL
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ROL')
CREATE TABLE ROL (
    id_rol INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(60) NOT NULL UNIQUE,
    estado BIT DEFAULT 1,
    fecha_registro DATETIME DEFAULT GETDATE()
)
GO

-- (2) TABLA MENU
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'MENU')
CREATE TABLE MENU (
    id_menu INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(60) NOT NULL UNIQUE,
    icono VARCHAR(60),
    estado BIT DEFAULT 1,
    fecha_registro DATETIME DEFAULT GETDATE()
)
GO

-- (3) TABLA SUBMENU
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SUBMENU')
CREATE TABLE SUBMENU (
    id_submenu INT PRIMARY KEY IDENTITY(1,1),
    fk_menu INT NOT NULL,
    nombre VARCHAR(60) NOT NULL UNIQUE,
    controlador VARCHAR(60) NOT NULL,
    vista VARCHAR(50) NOT NULL,
    icono VARCHAR(50),
    estado BIT DEFAULT 1,
    fecha_registro DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_SUBMENU_MENU FOREIGN KEY (fk_menu) REFERENCES MENU(id_menu) ON DELETE CASCADE
)
GO

-- (4) TABLA USUARIOS
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'USUARIOS')
CREATE TABLE USUARIOS (
    id_usuario INT PRIMARY KEY IDENTITY(1,1),
    pri_nombre VARCHAR(60) NOT NULL,
    seg_nombre VARCHAR(60),
    pri_apellido VARCHAR(60) NOT NULL,
    seg_apellido VARCHAR(60),
    usuario VARCHAR(50) NOT NULL UNIQUE,
    --contrasena VARBINARY(64) NOT NULL, -- Guardar el hash de la contrase�a
	contrasena VARCHAR(255) NOT NULL,
    correo VARCHAR(60) NOT NULL UNIQUE,
    telefono int UNIQUE,
    fk_rol INT NOT NULL,
    estado BIT DEFAULT 1,
    reestablecer BIT DEFAULT 1,
    fecha_registro DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_USUARIO_ROL FOREIGN KEY (fk_rol) REFERENCES ROL(id_rol) ON DELETE CASCADE
)
GO

-- (5) TABLA PERMISOS
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PERMISOS')
CREATE TABLE PERMISOS (
    id_permisos INT PRIMARY KEY IDENTITY(1,1),
    fk_rol INT NOT NULL,
    fk_submenu INT NOT NULL,
    estado BIT DEFAULT 1, -- Habilitar o deshabilitar permisos
    fecha_registro DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_PERMISOS_ROL FOREIGN KEY (fk_rol) REFERENCES ROL(id_rol) ON DELETE CASCADE,
    CONSTRAINT FK_PERMISOS_SUBMENU FOREIGN KEY (fk_submenu) REFERENCES SUBMENU(id_submenu) ON DELETE CASCADE
)
GO

-- (5) TABLA PERMISOS
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PERMISOS')
CREATE TABLE PERMISOS (
    id_permisos INT PRIMARY KEY IDENTITY(1,1),
    fk_rol INT NOT NULL,
    fk_submenu INT NOT NULL,
    estado BIT DEFAULT 1, -- Habilitar o deshabilitar permisos
    fecha_registro DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_PERMISOS_ROL FOREIGN KEY (fk_rol) REFERENCES ROL(id_rol) ON DELETE CASCADE,
    CONSTRAINT FK_PERMISOS_SUBMENU FOREIGN KEY (fk_submenu) REFERENCES SUBMENU(id_submenu) ON DELETE CASCADE
)
GO

-----------------------------------------------------TABLAS PARA LA PLANIFICACION-----------------------------------------------------

-- Tabla Asignatura
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ASIGNATURA')
CREATE TABLE ASIGNATURA (
    id_asignatura INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
	estado BIT DEFAULT 1,
	fecha_registro DATETIME DEFAULT GETDATE(),
);

GO

-- Tabla Carrera
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CARRERA')
CREATE TABLE CARRERA (
    id_carrera INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
	estado BIT DEFAULT 1,
	fecha_registro DATETIME DEFAULT GETDATE(),
);

GO

-- Tabla Departamento
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DEPARTAMENTO')
CREATE TABLE DEPARTAMENTO (
    id_departamento INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
	estado BIT DEFAULT 1,
	fecha_registro DATETIME DEFAULT GETDATE(),
);

GO

-- Tabla AreaConocimiento
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AREACONOCIMIENTO')
CREATE TABLE AREACONOCIMIENTO (
    id_area INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
	estado BIT DEFAULT 1,
	fecha_registro DATETIME DEFAULT GETDATE(),
);

GO

-- Tabla ComponenteCurricular
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'COMPONENTECURRICULAR')
CREATE TABLE COMPONENTECURRICULAR (
    id_componente_curricular INT PRIMARY KEY IDENTITY(1,1),    
	fk_asignatura INT NOT NULL,
    fk_carrera INT NOT NULL,
    fk_departamento INT NOT NULL,
    fk_area INT FOREIGN KEY REFERENCES AREACONOCIMIENTO(id_area),
	CONSTRAINT FK_COMPONENTECURRICULAR_ASIGNATURA FOREIGN KEY (fk_asignatura) REFERENCES ASIGNATURA(id_asignatura) ON DELETE CASCADE,
	CONSTRAINT FK_COMPONENTECURRICULAR_CARRERA FOREIGN KEY (fk_carrera) REFERENCES CARRERA(id_carrera) ON DELETE CASCADE,
	CONSTRAINT FK_COMPONENTECURRICULAR_DEPARTAMENTO FOREIGN KEY (fk_departamento) REFERENCES DEPARTAMENTO(id_departamento) ON DELETE CASCADE,
	CONSTRAINT FK_COMPONENTECURRICULAR_AREA FOREIGN KEY (fk_area) REFERENCES AREACONOCIMIENTO(id_area) ON DELETE CASCADE
);

GO

-- Tabla Semestre
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SEMESTRE')
CREATE TABLE SEMESTRE(
	id_semestre INT PRIMARY KEY IDENTITY(1,1),
	descripcion VARCHAR(255) NOT NULL,
	estado BIT DEFAULT 1,
	fecha_registro DATETIME DEFAULT GETDATE(),
)

GO

-- Tabla Periodo
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PERIODO')
CREATE TABLE PERIODO (
	id_periodo INT PRIMARY KEY IDENTITY(1,1),
	anio VARCHAR(255),
	fk_semestre INT NOT NULL,
	estado BIT DEFAULT 1,
	CONSTRAINT FK_PERIODO_AREA FOREIGN KEY (fk_semestre) REFERENCES SEMESTRE(id_semestre) ON DELETE CASCADE
);

GO

-----------------------------------------------------Etapa 1: Matriz de Integracion de Componentes-----------------------------------------------------
-- Tabla MatrizIntegracionComponentes
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'MATRIZINTEGRACIONCOMPONENTES')
CREATE TABLE MATRIZINTEGRACIONCOMPONENTES (
    id_matriz_integracion INT PRIMARY KEY IDENTITY(1,1),
	codigo_documento VARCHAR(255),
	fk_profesor INT NOT NULL,
	nombre_matriz_integracion_componente VARCHAR(255),

	--Competencias
	competencias VARCHAR(255),

	--Objetivos
    objetivo_anio VARCHAR(255),
    objetivo_semestre VARCHAR(255),
    objetivo_integrador VARCHAR(255),

    --Asignaturas / Descripcion (La tiene la tabla MatrizAsignatura)
	
	--Estrategia Integradora
    accion_integradora VARCHAR(255),
    tipo_evaluacion VARCHAR(50),
	fecha_registro DATETIME DEFAULT GETDATE(),
	CONSTRAINT FK_MIC_USUARIO FOREIGN KEY (fk_profesor) REFERENCES USUARIOS(id_usuario) ON DELETE CASCADE
);

GO

-- Tabla MatrizAsignatura
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'MATRIZASIGNATURA')
CREATE TABLE MATRIZASIGNATURA (
    id_matriz_asignatura INT PRIMARY KEY IDENTITY(1,1),
    fk_matriz_integracion INT NOT NULL,
    fk_asignatura INT NOT NULL,
	descripcion VARCHAR(255),
	CONSTRAINT FK_MATRIZASIGNATURA_MIC FOREIGN KEY (fk_matriz_integracion) REFERENCES MATRIZINTEGRACIONCOMPONENTES(id_matriz_integracion) ON DELETE CASCADE,
	CONSTRAINT FK_MATRIZASIGNATURA_ASIGNATURA FOREIGN KEY (fk_asignatura) REFERENCES ASIGNATURA(id_asignatura) ON DELETE CASCADE
);

GO

-----------------------------------------------------Etapa 2: Plan Didactico Semestral-----------------------------------------------------
-- Tabla PlanDidacticoSemestral
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PLANDIDACTICOSEMESTRAL')
CREATE TABLE PLANDIDACTICOSEMESTRAL (
    id_plan_didactico_semestral INT PRIMARY KEY IDENTITY(1,1),	
	fk_matriz_integracion INT NOT NULL,
    fk_profesor INT NOT NULL,
	codigo_documento VARCHAR(255),	
	nombre_plan_didactico_semestral VARCHAR(255),

	-- Datos Generales
	-- 1. Area del conocimiento
	-- 2. Departamento
	-- 3. Carrera
	-- 4. Profesor
    fk_componente_curricular INT FOREIGN KEY REFERENCES ComponenteCurricular(id_componente_curricular),

	-- 5. A�o y semestre
    fk_anio_semestre INT FOREIGN KEY REFERENCES Periodo(id_periodo),

	-- 6. Fecha de Inicio / Fecha de Finalizacion
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,

	-- A.	Eje disiplinar
	eje_disiplinar VARCHAR(255),

	-- B.	Nombre del Componente Curricular
	fk_asignatura INT NOT NULL,
	
	-- C.	Curr�culum
	curriculum VARCHAR(255),

	-- D.	Temas, horas y creditos	(En la tabla: TemaPlanificacionSemestral)

	-- E.	Competencias con las que va a contribuir
	competencias VARCHAR(255),

	-- F.	Objetivo integrador
	objetivo_integrador VARCHAR(255),

	-- G.	Eje Transversal (En la tabla: EjeTransversal)
	eje_transversal VARCHAR(255),

	-- TABLA DE MATRIZ DE PLANIFICACI�N SEMESTRAL (En la tabla: MatrizPlanificacionSemestral)

	-- h.	Bases Orientadoras de la Acci�n (BOA)
	-- i.	R�brica (s) de evaluaci�n
	-- j.	Recursos
	-- k.	Bibliograf�a fundamental
	bibliografia VARCHAR(255),
	fecha_registro DATETIME DEFAULT GETDATE(),
	CONSTRAINT FK_PLANDIDACTICOSEMESTRAL_MIC FOREIGN KEY (fk_matriz_integracion) REFERENCES MATRIZINTEGRACIONCOMPONENTES(id_matriz_integracion),
	CONSTRAINT FK_PLANDIDACTICOSEMESTRAL_USUARIO FOREIGN KEY (fk_profesor) REFERENCES USUARIOS(id_usuario),
	CONSTRAINT FK_PDS_COMPONENTE FOREIGN KEY (fk_componente_curricular) REFERENCES ComponenteCurricular(id_componente_curricular),
	CONSTRAINT FK_PDS_PERIODO FOREIGN KEY (fk_anio_semestre) REFERENCES Periodo(id_periodo),
	CONSTRAINT FK_PDS_ASIGNATURA FOREIGN KEY (fk_asignatura) REFERENCES Asignatura(id_asignatura)
);

GO

-- Tabla Temas de Planifiaci�n Semestral (D. TEMAS, HORAS CREDITOS)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TEMAPLANIFICACIONSEMESTRAL')
CREATE TABLE TEMAPLANIFICACIONSEMESTRAL (
    id_tema INT PRIMARY KEY IDENTITY(1,1),
    fk_plan_didactico_semestral INT NOT NULL,
    tema VARCHAR(100) NOT NULL,
    horas_teoricas INT,
    horas_laboratorio INT,
    horas_practicas INT,
    horas_investigacion INT,
	P_LAB_INV INT,
    creditos INT,
	CONSTRAINT FK_TEMAL_PLANNIFICACIONSEMESTRAL FOREIGN KEY (fk_plan_didactico_semestral) REFERENCES PLANDIDACTICOSEMESTRAL(id_plan_didactico_semestral) ON DELETE CASCADE,
);

GO

-- Tabla Competencia (E. COMPETENCIAS CON LAS QUE VA A CONTRIBUIR)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'COMPETENCIAS')
CREATE TABLE COMPETENCIA (
    id_competencia INT PRIMARY KEY IDENTITY(1,1),    
	fk_plan_didactico_semestral INT NOT NULL,
    tipo VARCHAR(50) NOT NULL, -- Gen�rica o Espec�fica
    descripcion VARCHAR(255) NOT NULL
	CONSTRAINT FK_COMPETENCIA_PDS FOREIGN KEY (fk_plan_didactico_semestral) REFERENCES PLANDIDACTICOSEMESTRAL(id_plan_didactico_semestral) ON DELETE CASCADE,
);

GO

-- Tabla Eje Transversal
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'EJESTRANSVERSAL')
CREATE TABLE EJESTRANSVERSAL (
    id_eje INT PRIMARY KEY IDENTITY(1,1),
    fk_plan_didactico_semestral INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    objetivo VARCHAR(255),
    estrategia_metodologica VARCHAR(255),
    estrategia_evaluacion VARCHAR(255),
	CONSTRAINT FK_EJESTRANSVERSAL_PDS FOREIGN KEY (fk_plan_didactico_semestral) REFERENCES PLANDIDACTICOSEMESTRAL(id_plan_didactico_semestral) ON DELETE CASCADE
);

GO

-- Tabla Matriz de Planifiacion Semestral
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'MATRIZPLANIFICACIONSEMESTRAL')
CREATE TABLE MATRIZPLANIFICACIONSEMESTRAL (
    id_matriz INT PRIMARY KEY IDENTITY(1,1),  
	fk_plan_didactico_semestral INT NOT NULL,
	
	--Numero de semanas
	numero_semana INT,

	--Objetivos de aprendizaje a lograr en el semestre
    objetivo_aprendizaje VARCHAR(255),

	--Contenidos escenciales
    contenidos_esenciales VARCHAR(255),

	--Estrategias de aprendizaje (Integradoras)
    estrategias_aprendizaje VARCHAR(255),

	--Estrategias de evaluacion (Integradoras)
    estrategias_evaluacion VARCHAR(255),

	--Tipo de evaluacion
    tipo_evaluacion VARCHAR(50),

	--Instrumento de evaluacion
    instrumento_evaluacion VARCHAR(100),

	--Evidencias de aprendizaje
    evidencias_aprendizaje VARCHAR(255),

	CONSTRAINT FK_MATRIZPLANIFICACIONSEMESTRAL_PDS FOREIGN KEY (fk_plan_didactico_semestral) REFERENCES PLANDIDACTICOSEMESTRAL(id_plan_didactico_semestral) ON DELETE CASCADE
);

GO

-----------------------------------------------------Etapa 3: Plan de Clases Diario-----------------------------------------------------
-- Tabla Plan de Clases Diario
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PLANCLASESDIARIO')
CREATE TABLE PLANCLASESDIARIO (
    id_plan_diario INT PRIMARY KEY IDENTITY(1,1),
	fk_plan_didactico_semestral INT NOT NULL,
	codigo_documento VARCHAR(255) NOT NULL,	
	nombre_plan_clases_diario VARCHAR(255) NOT NULL,

	-- 1.	Datos Generales
	-- Carrera (COMPONENTECURRICULAR)
	fk_componente_curricular INT NOT NULL,
	
	-- Eje (s)
	ejes VARCHAR(255),

	-- Componente curricular (as)
	fk_asignatura INT NOT NULL,

	-- Profesor
	fk_profesor INT NOT NULL,

	-- A�o y semestre
	fk_periodo INT NOT NULL,

	-- Competencia o competencias
	competencias VARCHAR(255),

	-- BOA
	BOA VARCHAR(255),

	-- Fecha de Inicio y de Finalizacion
	fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,          

	-- 2.	Aprendizaje
    objetivo_aprendizaje VARCHAR(255),
    tema_contenido VARCHAR(255),
    indicador_logro VARCHAR(255),

	-- 3.	Tareas o actividades de aprendizaje
    tareas_iniciales VARCHAR(255),
    tareas_desarrollo VARCHAR(255),
    tareas_sintesis VARCHAR(255),

	-- 4.	Evaluaci�n de los aprendizajes
    tipo_evaluacion VARCHAR(50),
    estrategia_evaluacion VARCHAR(255),
    instrumento_evaluacion VARCHAR(100),
    evidencias_aprendizaje VARCHAR(255),
	criterios_aprendizaje VARCHAR(255),
	indicadores_aprendizaje VARCHAR(255),
	nivel_aprendizaje VARCHAR(255),

	fecha_registro DATETIME DEFAULT GETDATE(),

	-- 5.	Anexos

	CONSTRAINT FK_PCD_PDS FOREIGN KEY (fk_plan_didactico_semestral) REFERENCES PlanDidacticoSemestral(id_plan_didactico_semestral),
    CONSTRAINT FK_PCD_COMPONENTE FOREIGN KEY (fk_componente_curricular) REFERENCES ComponenteCurricular(id_componente_curricular),
    CONSTRAINT FK_PCD_ASIGNATURA FOREIGN KEY (fk_asignatura) REFERENCES Asignatura(id_asignatura),
    CONSTRAINT FK_PCD_USUARIO FOREIGN KEY (fk_profesor) REFERENCES Usuarios(id_usuario),
    CONSTRAINT FK_PCD_PERIODO FOREIGN KEY (fk_periodo) REFERENCES Periodo(id_periodo)
);

GO

-- Tabla Anexo
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ANEXO')
CREATE TABLE ANEXO (
    id_anexo INT PRIMARY KEY IDENTITY(1,1),
    fk_plan_diario INT NOT NULL,
    nombre_archivo VARCHAR(255) NOT NULL,
    tipo_archivo VARCHAR(50) NOT NULL,
    ruta_archivo VARCHAR(255) NOT NULL,
    fecha_subida DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ANEXO_PCD FOREIGN KEY (fk_plan_diario) REFERENCES PlanClasesDiario(id_plan_diario)
);

GO


------------------------------------------------INSERT EN LAS TABLAS------------------------------------------------

-- REGISTROS EN TABLA ROL
INSERT INTO ROL(descripcion) 
VALUES 
    ('ADMINISTRADOR'),
    ('INTEGRADOR'),
    ('PROFESOR');

GO

-- REGISTROS EN TABLA MENU
INSERT INTO MENU(nombre, icono) 
VALUES
    ('Usuario', 'fas fa-users'),
    ('Matriz de Integracion', 'fas fa-table'),
    ('Plan Didactico Semestral', 'fas fa-bookmark'),
    ('Plan de Clases Diario', 'fas fa-boxes'),
    ('Reportes', 'far fa-file-pdf');

GO

-- REGISTROS EN TABLA SUBMENU
INSERT INTO SUBMENU(fk_menu, nombre, controlador, vista, icono) 
VALUES
    ((SELECT TOP 1 id_menu FROM MENU WHERE nombre = 'Usuario'), 'Rol', 'Usuario', 'Rol', 'fas fa-user-tag'),
    ((SELECT TOP 1 id_menu FROM MENU WHERE nombre = 'Usuario'), 'Asignar Permisos', 'Usuario', 'Permisos', 'fas fa-user-lock'),
    ((SELECT TOP 1 id_menu FROM MENU WHERE nombre = 'Usuario'), 'Usuarios', 'Usuario', 'Index', 'fas fa-users-cog');

GO

-- REGISTROS EN TABLA USUARIOS
INSERT INTO USUARIOS(pri_nombre, seg_nombre, pri_apellido, seg_apellido, usuario, contrasena, correo, telefono, fk_rol)
VALUES 
    ('Keneth', 'Ernesto', 'Macis', 'Flores', 'Keny', 
        'admin',
        'ken123oficial@gmail.com', 12345678,
        (SELECT TOP 1 id_rol FROM ROL WHERE descripcion = 'ADMINISTRADOR')),

	('admin', 'admin', 'admin', 'admin', 'admin', 
        'admin', 
        'admin@gmail.com', 87654321,
        (SELECT TOP 1 id_rol FROM ROL WHERE descripcion = 'ADMINISTRADOR'));

    --('admin', 'admin', 'admin', 'admin', 'admin', 
    --    CONVERT(VARBINARY(64), '29cfa0f8e37e40a1a7a723aa88eca2cc050f270417969bfbe753f6bc0919aefe'), 
    --    'admin@gmail.com', 
    --    (SELECT TOP 1 id_rol FROM ROL WHERE descripcion = 'INTEGRADOR'));
GO

-- REGISTROS EN TABLA PERMISOS

-- ADMINISTRADOR tiene acceso a todos los men�s y submen�s
INSERT INTO PERMISOS(fk_rol, fk_submenu, estado)
SELECT 
    (SELECT TOP 1 id_rol FROM ROL WHERE descripcion = 'ADMINISTRADOR'), 
    id_submenu, 
    1 
FROM SUBMENU;

GO

-- INTEGRADOR tiene acceso a todo excepto el men� 'Usuario'
INSERT INTO PERMISOS(fk_rol, fk_submenu, estado)
SELECT 
    (SELECT TOP 1 id_rol FROM ROL WHERE descripcion = 'INTEGRADOR'), 
    id_submenu, 
    CASE 
        WHEN (SELECT nombre FROM MENU WHERE id_menu = fk_menu) = 'Usuario' THEN 0 -- No tiene acceso al men� 'Usuario'
        ELSE 1 -- Tiene acceso a todo lo dem�s
    END 
FROM SUBMENU;

GO

-- PROFESOR tiene acceso solo a los men�s: Matriz de Integraci�n, Plan Did�ctico Semestral, Plan de Clases Diario
INSERT INTO PERMISOS(fk_rol, fk_submenu, estado)
SELECT 
    (SELECT TOP 1 id_rol FROM ROL WHERE descripcion = 'PROFESOR'), 
    id_submenu, 
    1 
FROM SUBMENU
WHERE fk_menu IN (
    SELECT id_menu FROM MENU 
    WHERE nombre IN ('Matriz de Integracion', 'Plan Didactico Semestral', 'Plan de Clases Diario')
);

GO

-- REGISTROS EN TABLA ASIGNATURA
INSERT INTO Asignatura (nombre) 
VALUES 
	('Hardware'), 
	('Dise�o Web'),
	('Software'),
	('Seguridad Inform�tica'),
	('Dise�o de Soluciones Educativas');

go

-- REGISTROS EN LA TABLA CARRERA
INSERT INTO Carrera (nombre) 
VALUES 
	('Inform�tica Educativa'),
	('Dise�o Grafico'),
	('Administraci�n Tur�stica y Hotelera'),
	('Ciencias Naturales'),
	('Ciencias Sociales'),
	('F�sica-Matem�tica'),
	('Ingl�s'),
	('Lengua y Literatura Hisp�nicas'),
	('Cultura y Artes'),
	('Danza'),
	('Educaci�n F�sica y Deportes'),
	('Educaci�n Musical'),
	('Traducci�n e Interpretaci�n en Lenguas Extranjeras'),
	('Turismo Sostenible');

go

INSERT INTO Departamento (nombre) 
VALUES 
	('Tecnolog�a Educativa'),
	('Multidisciplinario'),
	('Ense�anza de las Ciencias'),
	('Espa�ol'),
	('Lenguas Extranjeras'),
	('Pedagog�a'),
	('Administraci�n de Empresas'),
	('Contabilidad P�blica y Finanzas'),
	('Econom�a'),
	('Derecho'),
	('Ciencias Sociales y Pol�ticas'),
	('Ciencias de la Informaci�n y Comunicaci�n'),
	('Psicolog�a y Trabajo Social'),
	('Ciencias B�sicas Biom�dicas'),
	('Ciencias M�dico-quir�rgica'),
	('Salud Materno Infantil'),
	('Salud P�blica'),
	('Integrador de las Pr�cticas en Salud'),
	('Salud Visual'),
	('Salud Oral'),
	('Enfermer�a y Anestesia'),
	('Fisioterapia'),
	('Nutrici�n'),
	('Bioan�lisis cl�nico'),
	('Matem�ticas'),
	('Computaci�n'),
	('F�sica'),
	('Biolog�a'),
	('Qu�mica'),
	('Construcci�n'),
	('Tecnolog�a');

-- REGISTROS EN LA TABLA AREACONOCIMIENTO
INSERT INTO AreaConocimiento (nombre) 
VALUES 
	('Educaci�n, Arte y Humanidades'),
	('Ciencias Econ�micas y Administrativas'),
	('Ciencias Sociales y Jur�dicas'),
	('Ciencias de la Salud'),
	('Ciencias B�sicas y Tecnolog�a');

go

-- REGISTROS EN LA TABLA COMPONENTECURRICULAR
INSERT INTO ComponenteCurricular (fk_asignatura, fk_carrera, fk_departamento, fk_area)
VALUES 
	(1, 1, 1, 1),
	(2, 1, 1, 1),
	(3, 1, 1, 1),
	(4, 1, 1, 1),
	(5, 1, 1, 1);

go

INSERT INTO SEMESTRE (descripcion) VALUES ('Semestre I'), ('Semestre II')

GO

INSERT INTO PERIODO (anio, fk_semestre) VALUES ('2025', 1), ('2025', 2), ('2024', 1), ('2024', 2)

GO

----------------------------------------------PRUEBAS DE REGISTROS DE LAS TABLAS PRINCIPALES----------------------------------------------
INSERT INTO MatrizIntegracionComponentes (
    fk_profesor,    
    codigo_documento,
    nombre_matriz_integracion_componente,
    competencias,
    objetivo_anio,
    objetivo_semestre,
    objetivo_integrador,
    accion_integradora,
    tipo_evaluacion
)
VALUES (
    1, -- fk_profesor    
    'MIC-001', -- codigo_documento
    'Matriz de Integraci�n de Hardware', -- nombre_matriz_integracion_componente
    'Competencias en hardware', -- competencias
    'Integrar conocimientos de hardware y software', -- objetivo_anio
    'Desarrollar habilidades en hardware', -- objetivo_semestre
    'Crear soluciones educativas integradas', -- objetivo_integrador
    'Proyecto final integrador', -- accion_integradora
    'Sumativa' -- tipo_evaluacion
);

-- Asignatura 1: Hardware
INSERT INTO MatrizAsignatura (fk_matriz_integracion, fk_asignatura, descripcion)
VALUES (
    1, -- fk_matriz_integracion
    1, -- fk_asignatura (Hardware)
    'Requisitos de hardware para servidores' -- descripcion
);

INSERT INTO PlanDidacticoSemestral (
    fk_matriz_integracion,
    fk_profesor,
    codigo_documento,
    nombre_plan_didactico_semestral,
    fk_componente_curricular,
    fk_anio_semestre,
    fecha_inicio,
    fecha_fin,
    eje_disiplinar,
    fk_asignatura,
    curriculum,
    competencias,
    objetivo_integrador,
    eje_transversal,
    bibliografia
)
VALUES (
    1, -- fk_matriz_integracion
    1, -- fk_profesor
    'PDS-001', -- codigo_documento
    'Plan Did�ctico de Hardware', -- nombre_plan_didactico_semestral
    1, -- fk_componente_curricular
    1, -- fk_anio_semestre
    '2023-08-01', -- fecha_inicio
    '2023-12-15', -- fecha_fin
    'Integraci�n de hardware y software', -- eje_disiplinar
    1, -- fk_asignatura (Hardware)
    'Curr�culum de hardware', -- curriculum
    'Competencias en hardware', -- competencias
    'Crear soluciones educativas integradas', -- objetivo_integrador
    'Eje transversal de hardware', -- eje_transversal
    'Bibliograf�a de hardware' -- bibliografia
);

-- Tema 1: Introducci�n al Hardware
INSERT INTO TemaPlanificacionSemestral (
    fk_plan_didactico_semestral,
    tema,
    horas_teoricas,
    horas_laboratorio,
    horas_practicas,
    horas_investigacion,
    P_LAB_INV,
    creditos
)
VALUES (
    1, -- fk_plan_didactico_semestral (ID del Plan Did�ctico Semestral)
    'Introducci�n al Hardware', -- tema
    10, -- horas_teoricas
    5, -- horas_laboratorio
    5, -- horas_practicas
    2, -- horas_investigacion
    1, -- P_LAB_INV
    3 -- creditos
);

-- Tema 2: Componentes de Hardware
INSERT INTO TemaPlanificacionSemestral (
    fk_plan_didactico_semestral,
    tema,
    horas_teoricas,
    horas_laboratorio,
    horas_practicas,
    horas_investigacion,
    P_LAB_INV,
    creditos
)
VALUES (
    1, -- fk_plan_didactico_semestral
    'Componentes de Hardware', -- tema
    8, -- horas_teoricas
    4, -- horas_laboratorio
    4, -- horas_practicas
    2, -- horas_investigacion
    1, -- P_LAB_INV
    2 -- creditos
);

-- Matriz de Planificaci�n Semestral
INSERT INTO MatrizPlanificacionSemestral (
    fk_plan_didactico_semestral,
    numero_semana,
    objetivo_aprendizaje,
    contenidos_esenciales,
    estrategias_aprendizaje,
    estrategias_evaluacion,
    tipo_evaluacion,
    instrumento_evaluacion,
    evidencias_aprendizaje
)
VALUES (
    1, -- fk_plan_didactico_semestral (ID del Plan Did�ctico Semestral)
    1, -- numero_semana
    'Comprender los conceptos b�sicos de hardware', -- objetivo_aprendizaje
    'Introducci�n al hardware y sus componentes', -- contenidos_esenciales
    'Clases te�ricas y pr�cticas', -- estrategias_aprendizaje
    'Evaluaci�n por proyecto', -- estrategias_evaluacion
    'Sumativa', -- tipo_evaluacion
    'R�brica', -- instrumento_evaluacion
    'Lista de componentes identificados' -- evidencias_aprendizaje
);

INSERT INTO PlanClasesDiario (
    fk_plan_didactico_semestral,
    codigo_documento,
    nombre_plan_clases_diario,
    fk_componente_curricular,
    ejes,
    fk_asignatura,
    fk_profesor,
    fk_periodo,
    competencias,
    BOA,
    fecha_inicio,
    fecha_fin,
    objetivo_aprendizaje,
    tema_contenido,
    indicador_logro,
    tareas_iniciales,
    tareas_desarrollo,
    tareas_sintesis,
    tipo_evaluacion,
    estrategia_evaluacion,
    instrumento_evaluacion,
    evidencias_aprendizaje,
    criterios_aprendizaje,
    indicadores_aprendizaje,
    nivel_aprendizaje
)
VALUES (
    1, -- fk_plan_didactico_semestral
    'PCD-001', -- codigo_documento
    'Plan de Clases Diario de Hardware', -- nombre_plan_clases_diario
    1, -- fk_componente_curricular
    'Ejes de hardware', -- ejes
    1, -- fk_asignatura (Hardware)
    1, -- fk_profesor
    1, -- fk_periodo
    'Competencias en hardware', -- competencias
    'BOA de hardware', -- BOA
    '2023-10-15', -- fecha_inicio
    '2023-10-20', -- fecha_fin
    'Comprender los conceptos b�sicos de hardware', -- objetivo_aprendizaje
    'Introducci�n a los componentes de hardware', -- tema_contenido
    'El estudiante identifica los componentes de hardware', -- indicador_logro
    'Revisar conceptos previos', -- tareas_iniciales
    'Identificar componentes de hardware', -- tareas_desarrollo
    'Presentaci�n de los componentes identificados', -- tareas_sintesis
    'Sumativa', -- tipo_evaluacion
    'Evaluaci�n por proyecto', -- estrategia_evaluacion
    'R�brica', -- instrumento_evaluacion
    'Lista de componentes identificados', -- evidencias_aprendizaje
    'Precisi�n en la identificaci�n', -- criterios_aprendizaje
    'Uso correcto de terminolog�a', -- indicadores_aprendizaje
    'B�sico' -- nivel_aprendizaje
);
------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------PROCEDIMIENTOS ALMACENADOS------------------------------------------------
-- Iniciar Sesi�n
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_LoginUsuario')
DROP PROCEDURE usp_LoginUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerDetalleUsuario')
DROP PROCEDURE usp_ObtenerDetalleUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerPermisos')
DROP PROCEDURE usp_ObtenerPermisos
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ActualizarPermisos')
DROP PROCEDURE usp_ActualizarPermisos
GO

-- Usuario
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerUsuario')
DROP PROCEDURE usp_ObtenerUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RegistrarUsuario')
DROP PROCEDURE usp_RegistrarUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ModificarUsuario')
DROP PROCEDURE usp_ModificarUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EliminarUsuario')
DROP PROCEDURE usp_EliminarUsuario
GO

-- Roles
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerRoles')
DROP PROCEDURE usp_ObtenerRoles
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RegistrarRol')
DROP PROCEDURE usp_RegistrarRol
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ModificarRol')
DROP PROCEDURE usp_ModificarRol
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EliminarRol')
DROP PROCEDURE usp_EliminarRol
GO

CREATE PROCEDURE usp_LoginUsuario(    
	@Usuario VARCHAR(60),
    @Clave VARCHAR(100),
	@IdUsuario INT OUTPUT,
    @Mensaje VARCHAR(255) OUTPUT
)   
AS
BEGIN
    SET @IdUsuario = 0
    SET @Mensaje = ''

    -- Verificar si el usuario existe y est� activo
    IF EXISTS (SELECT * FROM USUARIOS WHERE usuario = @Usuario AND estado = 1)
    BEGIN
        -- Verificar si la contrase�a es correcta
        IF EXISTS (SELECT * FROM USUARIOS WHERE usuario = @Usuario AND contrasena = @Clave AND estado = 1)
        BEGIN
            SET @IdUsuario = (SELECT TOP 1 id_usuario FROM USUARIOS WHERE usuario = @Usuario AND contrasena = @Clave AND estado = 1)
            SET @Mensaje = 'Inicio de sesi�n exitoso'
        END
        ELSE
        BEGIN
            SET @Mensaje = 'Contrase�a incorrecta'
        END
    END
    ELSE
    BEGIN
        SET @Mensaje = 'El usuario no existe o est� inactivo'
    END
END
GO

DECLARE @IdUsuario INT
DECLARE @Mensaje VARCHAR(255)


EXEC usp_LoginUsuario
    @Usuario = 'admin',
    @Clave = 'admin',
    @IdUsuario = @IdUsuario OUTPUT,
    @Mensaje = @Mensaje OUTPUT

PRINT 'ID Usuario: ' + CAST(@IdUsuario AS VARCHAR)
PRINT 'Mensaje: ' + @Mensaje
GO


CREATE PROCEDURE usp_ObtenerDetalleUsuario
    @IdUsuario INT
AS
BEGIN
    SELECT 
        u.*,
        (SELECT * FROM ROL r WHERE r.id_rol = u.fk_rol FOR XML PATH(''), TYPE) AS 'DetalleRol',
        (
            SELECT m.nombre AS 'NombreMenu', m.icono,
            (
                SELECT sm.nombre AS 'NombreSubMenu', sm.controlador, sm.vista, sm.icono, p.estado
                FROM PERMISOS p
                INNER JOIN SUBMENU sm ON sm.id_submenu = p.fk_submenu
                INNER JOIN MENU m ON m.id_menu = sm.fk_menu
                WHERE p.fk_rol = u.fk_rol AND p.estado = 1
                FOR XML PATH('SubMenu'), TYPE
            ) AS 'DetalleSubMenu'
            FROM MENU m
            WHERE EXISTS (
                SELECT 1
                FROM PERMISOS p
                INNER JOIN SUBMENU sm ON sm.id_submenu = p.fk_submenu
                WHERE p.fk_rol = u.fk_rol AND sm.fk_menu = m.id_menu AND p.estado = 1
            )
            FOR XML PATH('Menu'), TYPE
        ) AS 'DetalleMenu'
    FROM USUARIOS u
    WHERE u.id_usuario = @IdUsuario
    FOR XML PATH(''), ROOT('Usuario')
END
GO

CREATE PROCEDURE usp_ObtenerPermisos
    @IdRol INT
AS
BEGIN
    SELECT 
        p.id_permisos,
        m.nombre AS 'Menu',
        sm.nombre AS 'SubMenu',
        p.estado
    FROM PERMISOS p
    INNER JOIN SUBMENU sm ON sm.id_submenu = p.fk_submenu
    INNER JOIN MENU m ON m.id_menu = sm.fk_menu
    WHERE p.fk_rol = @IdRol
END
GO

CREATE PROCEDURE usp_ActualizarPermisos
    @Detalle XML,
    @Resultado BIT OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        DECLARE @permisos TABLE (id_permisos INT, estado BIT)

        INSERT INTO @permisos (id_permisos, estado)
        SELECT 
            Node.Data.value('(IdPermisos)[1]', 'INT'),
            Node.Data.value('(Activo)[1]', 'BIT')
        FROM @Detalle.nodes('/DETALLE/PERMISO') Node(Data)

        UPDATE p
        SET p.estado = pe.estado
        FROM PERMISOS p
        INNER JOIN @permisos pe ON pe.id_permisos = p.id_permisos

        COMMIT
        SET @Resultado = 1
    END TRY
    BEGIN CATCH
        ROLLBACK
        SET @Resultado = 0
    END CATCH
END
GO

CREATE PROCEDURE usp_ObtenerUsuario
AS
BEGIN
    SELECT 
        u.id_usuario,
        u.pri_nombre,
        u.seg_nombre,
        u.pri_apellido,
        u.seg_apellido,
        u.usuario,
        u.correo,
        u.fk_rol,
        u.estado,
        u.fecha_registro,
        r.descripcion AS 'DescripcionRol'
    FROM USUARIOS u
    INNER JOIN ROL r ON r.id_rol = u.fk_rol
END
GO

CREATE PROCEDURE usp_RegistrarUsuario(
    @PriNombre VARCHAR(60),
    @SegNombre VARCHAR(60),
    @PriApellido VARCHAR(60),
    @SegApellido VARCHAR(60),
    @Usuario VARCHAR(50),
    @Clave VARCHAR(100),
    @Correo VARCHAR(60),
    @Telefono INT,
    @FkRol INT,
    @Estado BIT,    
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(255) OUTPUT
)
AS
BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''

    -- Verificar si el nombre de usuario ya existe
    IF EXISTS (SELECT * FROM USUARIOS WHERE usuario = @Usuario)
    BEGIN
        SET @Mensaje = 'El nombre de usuario ya est� en uso'
        RETURN
    END

    -- Verificar si el correo electr�nico ya existe
    IF EXISTS (SELECT * FROM USUARIOS WHERE correo = @Correo)
    BEGIN
        SET @Mensaje = 'El correo electr�nico ya est� registrado'
        RETURN
    END

    -- Insertar el nuevo usuario
    INSERT INTO USUARIOS (pri_nombre, seg_nombre, pri_apellido, seg_apellido, usuario, contrasena, correo, telefono, fk_rol, estado)
    VALUES (@PriNombre, @SegNombre, @PriApellido, @SegApellido, @Usuario, CONVERT(VARBINARY(64), @Clave), @Correo, @Telefono, @FkRol, @Estado)

    SET @Resultado = SCOPE_IDENTITY()
    SET @Mensaje = 'Usuario registrado exitosamente'
END
GO

CREATE PROCEDURE usp_ModificarUsuario
    @IdUsuario INT,
    @PriNombre VARCHAR(60),
    @SegNombre VARCHAR(60),
    @PriApellido VARCHAR(60),
    @SegApellido VARCHAR(60),
    @Usuario VARCHAR(50),
    @Clave VARCHAR(100),
    @Correo VARCHAR(60),
    @Telefono INT,
    @FkRol INT,
    @Estado BIT,

    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''

    -- Verificar si el usuario existe
    IF NOT EXISTS (SELECT 1 FROM USUARIOS WHERE id_usuario = @IdUsuario)
    BEGIN
        SET @Mensaje = 'El usuario no existe'
        RETURN
    END

    -- Verificar si el nombre de usuario ya existe (excluyendo al usuario actual)
    IF EXISTS (SELECT 1 FROM USUARIOS WHERE usuario = @Usuario AND id_usuario != @IdUsuario)
    BEGIN
        SET @Mensaje = 'El nombre de usuario ya est� en uso'
        RETURN
    END

    -- Verificar si el correo electr�nico ya existe (excluyendo al usuario actual)
    IF EXISTS (SELECT 1 FROM USUARIOS WHERE correo = @Correo AND id_usuario != @IdUsuario)
    BEGIN
        SET @Mensaje = 'El correo electr�nico ya est� registrado'
        RETURN
    END

    -- Actualizar el usuario
    UPDATE USUARIOS
    SET 
        pri_nombre = @PriNombre,
        seg_nombre = @SegNombre,
        pri_apellido = @PriApellido,
        seg_apellido = @SegApellido,
        usuario = @Usuario,
        contrasena = CONVERT(VARBINARY(64), @Clave),
        correo = @Correo,
        telefono = @Telefono,
        fk_rol = @FkRol,
        estado = @Estado
    WHERE id_usuario = @IdUsuario

    SET @Resultado = 1
    SET @Mensaje = 'Usuario actualizado exitosamente'
END
GO

CREATE PROCEDURE usp_EliminarUsuario
    @IdUsuario INT,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    
    IF EXISTS (SELECT 1 FROM USUARIOS WHERE id_usuario = @IdUsuario)
    BEGIN
        DELETE FROM USUARIOS WHERE id_usuario = @IdUsuario
        SET @Resultado = 1
    END
END
GO

CREATE PROCEDURE usp_ObtenerRoles
AS
BEGIN
    SELECT id_rol, descripcion, estado FROM ROL
END
GO

CREATE PROCEDURE usp_RegistrarRol
    @Descripcion VARCHAR(60),
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 1
    IF NOT EXISTS (SELECT * FROM ROL WHERE descripcion = @Descripcion)
    BEGIN
        DECLARE @IdRol INT
        INSERT INTO ROL (descripcion) VALUES (@Descripcion)
        SET @IdRol = SCOPE_IDENTITY()

        INSERT INTO PERMISOS (fk_rol, fk_submenu, estado)
        SELECT @IdRol, id_submenu, 0 FROM SUBMENU
    END
    ELSE
        SET @Resultado = 0
END
GO

CREATE PROCEDURE usp_ModificarRol
    @IdRol INT,
    @Descripcion VARCHAR(60),
    @Estado BIT,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 1
    IF NOT EXISTS (SELECT * FROM ROL WHERE descripcion = @Descripcion AND id_rol != @IdRol)
    BEGIN
        UPDATE ROL
        SET 
            descripcion = @Descripcion,
            estado = @Estado
        WHERE id_rol = @IdRol
    END
    ELSE
        SET @Resultado = 0
END
GO

CREATE PROCEDURE usp_EliminarRol
    @IdRol INT,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 1
    IF NOT EXISTS (SELECT * FROM USUARIOS WHERE fk_rol = @IdRol)
    BEGIN
        DELETE FROM PERMISOS WHERE fk_rol = @IdRol
        DELETE FROM ROL WHERE id_rol = @IdRol
    END
    ELSE
        SET @Resultado = 0
END
GO

select * from USUARIOS