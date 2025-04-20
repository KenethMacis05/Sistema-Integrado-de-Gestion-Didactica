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

-- (2) TABLA CONTROLLER
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CONTROLLER')
CREATE TABLE CONTROLLER (
    id_controlador INT PRIMARY KEY IDENTITY(1,1),    
    controlador VARCHAR(60) NOT NULL,
    accion VARCHAR(50) NOT NULL,
    descripcion VARCHAR(100),
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Vista', 'API')), -- Solo 2 tipos claros
	estado BIT DEFAULT 1, 
    fecha_registro DATETIME DEFAULT GETDATE()
    CONSTRAINT UQ_CONTROLLER_ACCION UNIQUE (controlador, accion)
)
GO

-- (3) TABLA MENU
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'MENU')
CREATE TABLE MENU (
    id_menu INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(60) NOT NULL,
    fk_controlador INT NULL, -- Solo para elementos que ejecutan una acción
    icono VARCHAR(60),
    orden INT DEFAULT 0,
    estado BIT DEFAULT 1,	
    fecha_registro DATETIME DEFAULT GETDATE()
    CONSTRAINT FK_MENU_CONTROLLER FOREIGN KEY (fk_controlador) REFERENCES CONTROLLER(id_controlador)
)
GO

-- (4) TABLA PERMISOS
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PERMISOS')
CREATE TABLE PERMISOS (
    id_permiso INT PRIMARY KEY IDENTITY(1,1),
    fk_rol INT NOT NULL,
    fk_controlador INT NOT NULL,
    estado BIT DEFAULT 1,	
    fecha_registro DATETIME DEFAULT GETDATE()
    CONSTRAINT FK_PERMISO_ROL FOREIGN KEY (fk_rol) REFERENCES ROL(id_rol) ON DELETE CASCADE,
    CONSTRAINT FK_PERMISO_CONTROLLER FOREIGN KEY (fk_controlador) REFERENCES CONTROLLER(id_controlador) ON DELETE CASCADE,
    CONSTRAINT UQ_PERMISO UNIQUE (fk_rol, fk_controlador)
)
GO

-- (4) TABLA MENU_ROL
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'MENU_ROL')
CREATE TABLE MENU_ROL (
    id_menu_rol INT PRIMARY KEY IDENTITY(1,1),
    fk_rol INT NOT NULL,
    fk_menu INT NOT NULL,
    estado BIT DEFAULT 1,	
    fecha_registro DATETIME DEFAULT GETDATE()
    CONSTRAINT FK_MENUROL_ROL FOREIGN KEY (fk_rol) REFERENCES ROL(id_rol) ON DELETE CASCADE,
    CONSTRAINT FK_MENUROL_MENU FOREIGN KEY (fk_menu) REFERENCES MENU(id_menu) ON DELETE CASCADE,
    CONSTRAINT UQ_MENUROL UNIQUE (fk_rol, fk_menu)
)
GO

-- (5) TABLA USUARIOS
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'USUARIOS')
CREATE TABLE USUARIOS (
    id_usuario INT PRIMARY KEY IDENTITY(1,1),
    pri_nombre VARCHAR(60) NOT NULL,
    seg_nombre VARCHAR(60),
    pri_apellido VARCHAR(60) NOT NULL,
    seg_apellido VARCHAR(60),
    usuario VARCHAR(50) NOT NULL UNIQUE,
    --contrasena VARBINARY(64) NOT NULL, -- Guardar el hash de la contraseña
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

--------------------------------------------------TABLAS PARA LA GESTION DE ARCHIVOS--------------------------------------------------

-- (1) TABLA CARPETA
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CARPETA')
CREATE TABLE CARPETA (
    id_carpeta INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(60) NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE(),
    fecha_eliminacion DATETIME DEFAULT NULL,
    estado BIT DEFAULT 1,
	carpeta_padre INT DEFAULT NULL,
	fk_id_usuario INT NOT NULL,
	CONSTRAINT FK_CARPETA_USUARIO FOREIGN KEY (fk_id_usuario) REFERENCES USUARIOS(id_usuario) ON DELETE CASCADE,
	CONSTRAINT FK_CARPETA_PADRE FOREIGN KEY (carpeta_padre) REFERENCES CARPETA(id_carpeta)
)
GO

-- (2) TABLA ARCHIVO
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ARCHIVO')
CREATE TABLE ARCHIVO (
	id_archivo INT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(60) NOT NULL,
	ruta VARCHAR(255),
	size INT NOT NULL,
	tipo VARCHAR(50) NOT NULL,	
	fecha_subida DATETIME DEFAULT GETDATE(),
	fecha_eliminacion DATETIME DEFAULT NULL,
	estado BIT DEFAULT 1,
	fk_id_carpeta INT NOT NULL,
	CONSTRAINT FK_ARCHIVO_CARPETA FOREIGN KEY (fk_id_carpeta) REFERENCES CARPETA(id_carpeta) ON DELETE CASCADE
)
GO

-- (3) TABLA ARCHIVO/CARPETAS COMPARTIDAS
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DETALLEARCHIVO')
CREATE TABLE DETALLEARCHIVO (
	id_detalle_archivo INT PRIMARY KEY IDENTITY(1,1),	
	correo VARCHAR(60) NOT NULL,
	estado BIT DEFAULT 1,
	fecha_compartida DATETIME DEFAULT GETDATE(),
	fk_id_archivo INT NOT NULL,
	fk_id_carpeta INT NOT NULL,
	fk_id_usuario INT NOT NULL,
	CONSTRAINT FK_DETALLEARCHIVO_ARCHIVO FOREIGN KEY (fk_id_archivo) REFERENCES ARCHIVO(id_archivo),
	CONSTRAINT FK_DETALLEARCHIVO_CARPETA FOREIGN KEY (fk_id_carpeta) REFERENCES CARPETA(id_carpeta),
	CONSTRAINT FK_DETALLEARCHIVO_USUARIO FOREIGN KEY (fk_id_usuario) REFERENCES USUARIOS(id_usuario) ON DELETE CASCADE
)
GO
-----------------------------------------------------TABLAS PARA LA PLANIFICACION-----------------------------------------------------

-- (1) Tabla Asignatura
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ASIGNATURA')
CREATE TABLE ASIGNATURA (
    id_asignatura INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
	estado BIT DEFAULT 1,
	fecha_registro DATETIME DEFAULT GETDATE(),
);

GO

-- (2) Tabla Carrera
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CARRERA')
CREATE TABLE CARRERA (
    id_carrera INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
	estado BIT DEFAULT 1,
	fecha_registro DATETIME DEFAULT GETDATE(),
);

GO

-- (3) Tabla Departamento
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DEPARTAMENTO')
CREATE TABLE DEPARTAMENTO (
    id_departamento INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
	estado BIT DEFAULT 1,
	fecha_registro DATETIME DEFAULT GETDATE(),
);

GO

-- (4) Tabla AreaConocimiento
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AREACONOCIMIENTO')
CREATE TABLE AREACONOCIMIENTO (
    id_area INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
	estado BIT DEFAULT 1,
	fecha_registro DATETIME DEFAULT GETDATE(),
);

GO

-- (5) Tabla ComponenteCurricular
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

-- (6) Tabla Semestre
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SEMESTRE')
CREATE TABLE SEMESTRE(
	id_semestre INT PRIMARY KEY IDENTITY(1,1),
	descripcion VARCHAR(255) NOT NULL,
	estado BIT DEFAULT 1,
	fecha_registro DATETIME DEFAULT GETDATE(),
)

GO

-- (7) Tabla Periodo
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
-- (1) Tabla MatrizIntegracionComponentes
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

-- (2) Tabla MatrizAsignatura
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
-- (1) Tabla PlanDidacticoSemestral
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

	-- 5. Año y semestre
    fk_anio_semestre INT FOREIGN KEY REFERENCES Periodo(id_periodo),

	-- 6. Fecha de Inicio / Fecha de Finalizacion
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,

	-- A.	Eje disiplinar
	eje_disiplinar VARCHAR(255),

	-- B.	Nombre del Componente Curricular
	fk_asignatura INT NOT NULL,
	
	-- C.	Currículum
	curriculum VARCHAR(255),

	-- D.	Temas, horas y creditos	(En la tabla: TemaPlanificacionSemestral)

	-- E.	Competencias con las que va a contribuir
	competencias VARCHAR(255),

	-- F.	Objetivo integrador
	objetivo_integrador VARCHAR(255),

	-- G.	Eje Transversal (En la tabla: EjeTransversal)
	eje_transversal VARCHAR(255),

	-- TABLA DE MATRIZ DE PLANIFICACIÓN SEMESTRAL (En la tabla: MatrizPlanificacionSemestral)

	-- h.	Bases Orientadoras de la Acción (BOA)
	-- i.	Rúbrica (s) de evaluación
	-- j.	Recursos
	-- k.	Bibliografía fundamental
	bibliografia VARCHAR(255),
	fecha_registro DATETIME DEFAULT GETDATE(),
	CONSTRAINT FK_PLANDIDACTICOSEMESTRAL_MIC FOREIGN KEY (fk_matriz_integracion) REFERENCES MATRIZINTEGRACIONCOMPONENTES(id_matriz_integracion),
	CONSTRAINT FK_PLANDIDACTICOSEMESTRAL_USUARIO FOREIGN KEY (fk_profesor) REFERENCES USUARIOS(id_usuario),
	CONSTRAINT FK_PDS_COMPONENTE FOREIGN KEY (fk_componente_curricular) REFERENCES ComponenteCurricular(id_componente_curricular),
	CONSTRAINT FK_PDS_PERIODO FOREIGN KEY (fk_anio_semestre) REFERENCES Periodo(id_periodo),
	CONSTRAINT FK_PDS_ASIGNATURA FOREIGN KEY (fk_asignatura) REFERENCES Asignatura(id_asignatura)
);

GO

-- (2) Tabla Temas de Planifiación Semestral (D. TEMAS, HORAS CREDITOS)
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

-- (3) Tabla Competencia (E. COMPETENCIAS CON LAS QUE VA A CONTRIBUIR)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'COMPETENCIAS')
CREATE TABLE COMPETENCIA (
    id_competencia INT PRIMARY KEY IDENTITY(1,1),    
	fk_plan_didactico_semestral INT NOT NULL,
    tipo VARCHAR(50) NOT NULL, -- Genérica o Específica
    descripcion VARCHAR(255) NOT NULL
	CONSTRAINT FK_COMPETENCIA_PDS FOREIGN KEY (fk_plan_didactico_semestral) REFERENCES PLANDIDACTICOSEMESTRAL(id_plan_didactico_semestral) ON DELETE CASCADE,
);

GO

-- (4) Tabla Eje Transversal
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

-- (5) Tabla Matriz de Planifiacion Semestral
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
-- (1) Tabla Plan de Clases Diario
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

	-- Año y semestre
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

	-- 4.	Evaluación de los aprendizajes
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

-- (2) Tabla Anexo
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