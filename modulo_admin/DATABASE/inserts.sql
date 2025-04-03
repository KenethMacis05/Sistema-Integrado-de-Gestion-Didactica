------------------------------------------------INSERT EN LAS TABLAS------------------------------------------------

-- (1) REGISTROS EN TABLA ROL
INSERT INTO ROL(descripcion) 
VALUES 
    ('ADMINISTRADOR'),
    ('INTEGRADOR'),
    ('PROFESOR');

GO
--------------------------------------------------------------------------------------------------------------------

-- (2) REGISTROS EN TABLA MENU
INSERT INTO MENU(nombre, icono) 
VALUES
    ('Usuario', 'fas fa-users'),
    ('Matriz de Integracion', 'fas fa-table'),
    ('Plan Didactico Semestral', 'fas fa-bookmark'),
    ('Plan de Clases Diario', 'fas fa-boxes'),
    ('Reportes', 'far fa-file-pdf');

GO
--------------------------------------------------------------------------------------------------------------------

-- (3) REGISTROS EN TABLA SUBMENU
INSERT INTO SUBMENU(fk_menu, nombre, controlador, vista, icono) 
VALUES
    ((SELECT TOP 1 id_menu FROM MENU WHERE nombre = 'Usuario'), 'Rol', 'Usuario', 'Rol', 'fas fa-user-tag'),
    ((SELECT TOP 1 id_menu FROM MENU WHERE nombre = 'Usuario'), 'Asignar Permisos', 'Usuario', 'Permisos', 'fas fa-user-lock'),
    ((SELECT TOP 1 id_menu FROM MENU WHERE nombre = 'Usuario'), 'Usuarios', 'Usuario', 'Index', 'fas fa-users-cog');

GO
--------------------------------------------------------------------------------------------------------------------

-- (4) REGISTROS EN TABLA USUARIOS
INSERT INTO USUARIOS(pri_nombre, seg_nombre, pri_apellido, seg_apellido, usuario, contrasena, correo, telefono, fk_rol)
VALUES 
    ('Keneth', 'Ernesto', 'Macis', 'Flores', 'Keny', 
        '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
        'ken123oficial@gmail.com', 12345678,
        (SELECT TOP 1 id_rol FROM ROL WHERE descripcion = 'ADMINISTRADOR')),

	('admin', 'admin', 'admin', 'admin', 'admin', 
        '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 
        'admin@gmail.com', 87654321,
        (SELECT TOP 1 id_rol FROM ROL WHERE descripcion = 'ADMINISTRADOR'));

GO
--------------------------------------------------------------------------------------------------------------------

-- (5) REGISTROS EN TABLA PERMISOS

-- ADMINISTRADOR tiene acceso a todos los menús y submenús
INSERT INTO PERMISOS(fk_rol, fk_submenu, estado)
SELECT 
    (SELECT TOP 1 id_rol FROM ROL WHERE descripcion = 'ADMINISTRADOR'), 
    id_submenu, 
    1 
FROM SUBMENU;

GO

-- INTEGRADOR tiene acceso a todo excepto el menú 'Usuario'
INSERT INTO PERMISOS(fk_rol, fk_submenu, estado)
SELECT 
    (SELECT TOP 1 id_rol FROM ROL WHERE descripcion = 'INTEGRADOR'), 
    id_submenu, 
    CASE 
        WHEN (SELECT nombre FROM MENU WHERE id_menu = fk_menu) = 'Usuario' THEN 0 -- No tiene acceso al menú 'Usuario'
        ELSE 1 -- Tiene acceso a todo lo demás
    END 
FROM SUBMENU;

GO

-- PROFESOR tiene acceso solo a los menús: Matriz de Integración, Plan Didáctico Semestral, Plan de Clases Diario
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

--------------------------------------------------------------------------------------------------------------------

-- (1) REGISTROS EN TABLA CARPETA
INSERT INTO CARPETA (nombre, fk_id_usuario) 
    VALUES ('Fotos', 1), ('Documentos', 1), ('Videos', 1), ('Música', 1),
           ('Fotos', 2), ('Documentos', 2), ('Videos', 2), ('Música', 2)
GO

-- (2) REGISTROS EN TABLA ARCHIVO
INSERT INTO ARCHIVO (nombre, tipo, fk_id_carpeta) 
    VALUES ('foto1.jpg', 'imagen', 1), ('documento1.pdf', 'documento', 2), 
           ('video1.mp4', 'video', 3), ('musica1.mp3', 'audio', 4),
           ('foto2.jpg', 'imagen', 5), ('documento2.pdf', 'documento', 6), 
           ('video2.mp4', 'video', 7), ('musica2.mp3', 'audio', 8)
GO

-- (3) REGISTROS EN TABLA DETALLEARCHIVO
INSERT INTO DETALLEARCHIVO (correo, fk_id_archivo, fk_id_carpeta, fk_id_usuario)
VALUES 
    ('ken123oficial@gmail.com', 1, 1, 1),
    ('admin@gmail.com', 2, 2, 2)
GO
--------------------------------------------------------------------------------------------------------------------

-- (6) REGISTROS EN TABLA ASIGNATURA
INSERT INTO Asignatura (nombre) 
VALUES 
	('Hardware'), 
	('Diseño Web'),
	('Software'),
	('Seguridad Informática'),
	('Diseño de Soluciones Educativas');

GO
--------------------------------------------------------------------------------------------------------------------

-- (7) REGISTROS EN LA TABLA CARRERA
INSERT INTO Carrera (nombre) 
VALUES 
	('Informática Educativa'),
	('Diseño Grafico'),
	('Administración Turística y Hotelera'),
	('Ciencias Naturales'),
	('Ciencias Sociales'),
	('Física-Matemática'),
	('Inglés'),
	('Lengua y Literatura Hispánicas'),
	('Cultura y Artes'),
	('Danza'),
	('Educación Física y Deportes'),
	('Educación Musical'),
	('Traducción e Interpretación en Lenguas Extranjeras'),
	('Turismo Sostenible');

GO
--------------------------------------------------------------------------------------------------------------------

-- (8) REGISTROS EN LA TABLA DEPARTAMENTO
INSERT INTO Departamento (nombre) 
VALUES 
	('Tecnología Educativa'),
	('Multidisciplinario'),
	('Enseñanza de las Ciencias'),
	('Español'),
	('Lenguas Extranjeras'),
	('Pedagogía'),
	('Administración de Empresas'),
	('Contabilidad Pública y Finanzas'),
	('Economía'),
	('Derecho'),
	('Ciencias Sociales y Políticas'),
	('Ciencias de la Información y Comunicación'),
	('Psicología y Trabajo Social'),
	('Ciencias Básicas Biomédicas'),
	('Ciencias Médico-quirúrgica'),
	('Salud Materno Infantil'),
	('Salud Pública'),
	('Integrador de las Prácticas en Salud'),
	('Salud Visual'),
	('Salud Oral'),
	('Enfermería y Anestesia'),
	('Fisioterapia'),
	('Nutrición'),
	('Bioanálisis clínico'),
	('Matemáticas'),
	('Computación'),
	('Física'),
	('Biología'),
	('Química'),
	('Construcción'),
	('Tecnología');

GO
--------------------------------------------------------------------------------------------------------------------

-- (9) REGISTROS EN LA TABLA AREACONOCIMIENTO
INSERT INTO AreaConocimiento (nombre) 
VALUES 
	('Educación, Arte y Humanidades'),
	('Ciencias Económicas y Administrativas'),
	('Ciencias Sociales y Jurídicas'),
	('Ciencias de la Salud'),
	('Ciencias Básicas y Tecnología');

GO
--------------------------------------------------------------------------------------------------------------------

-- (10) REGISTROS EN LA TABLA COMPONENTECURRICULAR
INSERT INTO ComponenteCurricular (fk_asignatura, fk_carrera, fk_departamento, fk_area)
VALUES 
	(1, 1, 1, 1),
	(2, 1, 1, 1),
	(3, 1, 1, 1),
	(4, 1, 1, 1),
	(5, 1, 1, 1);

GO
--------------------------------------------------------------------------------------------------------------------

-- (11) REGISTROS EN LA TABLA SEMESTRE
INSERT INTO SEMESTRE (descripcion) VALUES ('Semestre I'), ('Semestre II')

GO
--------------------------------------------------------------------------------------------------------------------

-- (12) REGISTROS EN LA TABLA PERIODO
INSERT INTO PERIODO (anio, fk_semestre) VALUES ('2025', 1), ('2025', 2), ('2024', 1), ('2024', 2)

GO
--------------------------------------------------------------------------------------------------------------------

--/////////////////////////////////PRUEBAS DE REGISTROS DE LAS TABLAS PRINCIPALES/////////////////////////////////--

-- (13) REGISTROS EN LA TABLA MATRIZINTEGRACIONCOMPONENTES
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
    'Matriz de Integración de Hardware', -- nombre_matriz_integracion_componente
    'Competencias en hardware', -- competencias
    'Integrar conocimientos de hardware y software', -- objetivo_anio
    'Desarrollar habilidades en hardware', -- objetivo_semestre
    'Crear soluciones educativas integradas', -- objetivo_integrador
    'Proyecto final integrador', -- accion_integradora
    'Sumativa' -- tipo_evaluacion
);

GO
--------------------------------------------------------------------------------------------------------------------

-- (14) REGISTROS EN LA TABLA MATRIZASIGNATURA

-- Asignatura 1: Hardware
INSERT INTO MatrizAsignatura (fk_matriz_integracion, fk_asignatura, descripcion)
VALUES (
    1, -- fk_matriz_integracion
    1, -- fk_asignatura (Hardware)
    'Requisitos de hardware para servidores' -- descripcion
);

-- Asignatura 2: Diseño Web
INSERT INTO MatrizAsignatura (fk_matriz_integracion, fk_asignatura, descripcion)
VALUES (
    1, -- fk_matriz_integracion
    2, -- fk_asignatura (Diseño Web)
    'Diseño de páginas web' -- descripcion
);

-- Asignatura 3: Software
INSERT INTO MatrizAsignatura (fk_matriz_integracion, fk_asignatura, descripcion)
VALUES (
    1, -- fk_matriz_integracion
    3, -- fk_asignatura (Software)
    'Desarrollo de software' -- descripcion
);

-- Asignatura 4: Seguridad Informática
INSERT INTO MatrizAsignatura (fk_matriz_integracion, fk_asignatura, descripcion)
VALUES (
    1, -- fk_matriz_integracion
    4, -- fk_asignatura (Seguridad Informática)
    'Seguridad en redes' -- descripcion
);

GO
--------------------------------------------------------------------------------------------------------------------

-- (15) REGISTROS EN LA TABLA PLANIFICACIONSEMESTRAL
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
    'Plan Didáctico de Hardware', -- nombre_plan_didactico_semestral
    1, -- fk_componente_curricular
    1, -- fk_anio_semestre
    '2023-08-01', -- fecha_inicio
    '2023-12-15', -- fecha_fin
    'Integración de hardware y software', -- eje_disiplinar
    1, -- fk_asignatura (Hardware)
    'Currículum de hardware', -- curriculum
    'Competencias en hardware', -- competencias
    'Crear soluciones educativas integradas', -- objetivo_integrador
    'Eje transversal de hardware', -- eje_transversal
    'Bibliografía de hardware' -- bibliografia
);

GO
--------------------------------------------------------------------------------------------------------------------

-- (16) REGISTROS EN LA TABLA TEMPLANIFICACIONSEMESTRAL

-- Tema 1: Introducción al Hardware
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
    1, -- fk_plan_didactico_semestral (ID del Plan Didáctico Semestral)
    'Introducción al Hardware', -- tema
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

GO
--------------------------------------------------------------------------------------------------------------------

-- (17) REGISTROS EN LA TABLA MATRIZPLANIFICACIONSEMESTRAL
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
    1, -- fk_plan_didactico_semestral (ID del Plan Didáctico Semestral)
    1, -- numero_semana
    'Comprender los conceptos básicos de hardware', -- objetivo_aprendizaje
    'Introducción al hardware y sus componentes', -- contenidos_esenciales
    'Clases teóricas y prácticas', -- estrategias_aprendizaje
    'Evaluación por proyecto', -- estrategias_evaluacion
    'Sumativa', -- tipo_evaluacion
    'Rúbrica', -- instrumento_evaluacion
    'Lista de componentes identificados' -- evidencias_aprendizaje
);

GO
--------------------------------------------------------------------------------------------------------------------

-- (18) REGISTROS EN LA TABLA PLANCLASESDIARIO
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
    'Comprender los conceptos básicos de hardware', -- objetivo_aprendizaje
    'Introducción a los componentes de hardware', -- tema_contenido
    'El estudiante identifica los componentes de hardware', -- indicador_logro
    'Revisar conceptos previos', -- tareas_iniciales
    'Identificar componentes de hardware', -- tareas_desarrollo
    'Presentación de los componentes identificados', -- tareas_sintesis
    'Sumativa', -- tipo_evaluacion
    'Evaluación por proyecto', -- estrategia_evaluacion
    'Rúbrica', -- instrumento_evaluacion
    'Lista de componentes identificados', -- evidencias_aprendizaje
    'Precisión en la identificación', -- criterios_aprendizaje
    'Uso correcto de terminología', -- indicadores_aprendizaje
    'Básico' -- nivel_aprendizaje
);

GO