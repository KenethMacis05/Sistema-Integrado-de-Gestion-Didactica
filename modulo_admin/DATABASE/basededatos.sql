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
    contrasena VARBINARY(64) NOT NULL, -- Guardar el hash de la contraseña
    correo VARCHAR(60) NOT NULL UNIQUE,
    fk_rol INT NOT NULL,
    estado BIT DEFAULT 1,
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
INSERT INTO USUARIOS(pri_nombre, seg_nombre, pri_apellido, seg_apellido, usuario, contrasena, correo, fk_rol)
VALUES 
    ('Keneth', 'Ernesto', 'Macis', 'Flores', 'Keny', 
        CONVERT(VARBINARY(64), '7932b2e116b076a54f452848eaabd5857f61bd957fe8a218faf216f24c9885bb'), 
        'ken123oficial@gmail.com', 
        (SELECT TOP 1 id_rol FROM ROL WHERE descripcion = 'ADMINISTRADOR')),

    ('admin', 'admin', 'admin', 'admin', 'admin', 
        CONVERT(VARBINARY(64), '29cfa0f8e37e40a1a7a723aa88eca2cc050f270417969bfbe753f6bc0919aefe'), 
        'admin@gmail.com', 
        (SELECT TOP 1 id_rol FROM ROL WHERE descripcion = 'INTEGRADOR'));
GO

-- REGISTROS EN TABLA PERMISOS

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

-- Iniciar Sesión
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

CREATE PROCEDURE usp_LoginUsuario
    @Correo VARCHAR(60),
    @Clave VARCHAR(100),
    @IdUsuario INT OUTPUT
AS
BEGIN
    SET @IdUsuario = 0
    IF EXISTS (SELECT * FROM USUARIOS WHERE Correo = @Correo AND contrasena = CONVERT(VARBINARY(64), @Clave) AND estado = 1)
        SET @IdUsuario = (SELECT TOP 1 id_usuario FROM USUARIOS WHERE Correo = @Correo AND contrasena = CONVERT(VARBINARY(64), @Clave) AND estado = 1)
END
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

CREATE PROCEDURE usp_RegistrarUsuario
    @PriNombre VARCHAR(60),
    @SegNombre VARCHAR(60),
    @PriApellido VARCHAR(60),
    @SegApellido VARCHAR(60),
    @Usuario VARCHAR(50),
    @Clave VARCHAR(100),
    @Correo VARCHAR(60),
    @FkRol INT,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 1
    IF NOT EXISTS (SELECT * FROM USUARIOS WHERE correo = @Correo)
    BEGIN
        INSERT INTO USUARIOS (pri_nombre, seg_nombre, pri_apellido, seg_apellido, usuario, contrasena, correo, fk_rol)
        VALUES (@PriNombre, @SegNombre, @PriApellido, @SegApellido, @Usuario, CONVERT(VARBINARY(64), @Clave), @Correo, @FkRol)
    END
    ELSE
        SET @Resultado = 0
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
    @FkRol INT,
    @Estado BIT,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 1
    IF NOT EXISTS (SELECT * FROM USUARIOS WHERE correo = @Correo AND id_usuario != @IdUsuario)
    BEGIN
        UPDATE USUARIOS
        SET 
            pri_nombre = @PriNombre,
            seg_nombre = @SegNombre,
            pri_apellido = @PriApellido,
            seg_apellido = @SegApellido,
            usuario = @Usuario,
            contrasena = CONVERT(VARBINARY(64), @Clave),
            correo = @Correo,
            fk_rol = @FkRol,
            estado = @Estado
        WHERE id_usuario = @IdUsuario
    END
    ELSE
        SET @Resultado = 0
END
GO

CREATE PROCEDURE usp_EliminarUsuario
    @IdUsuario INT,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 1
    IF NOT EXISTS (SELECT * FROM USUARIOS WHERE id_usuario = @IdUsuario)
    BEGIN
        DELETE FROM USUARIOS WHERE id_usuario = @IdUsuario
    END
    ELSE
        SET @Resultado = 0
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