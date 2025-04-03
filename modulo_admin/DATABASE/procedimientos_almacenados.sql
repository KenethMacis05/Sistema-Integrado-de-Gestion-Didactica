------------------------------------------------PROCEDIMIENTOS ALMACENADOS------------------------------------------------

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

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerUsuario')
DROP PROCEDURE usp_ObtenerUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RegistrarUsuario')
DROP PROCEDURE usp_RegistrarUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ModificarUsuario')
DROP PROCEDURE usp_ModificarUsuario
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ModificarContrasena')
DROP PROCEDURE usp_ModificarContrasena
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EliminarUsuario')
DROP PROCEDURE usp_EliminarUsuario
GO

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

--------------------------------------------------------------------------------------------------------------------

-- (1) PROCEDIMIENTO ALMACENADO PARA INICIAR SESIÓN DE USUARIO
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

    -- Verificar si el usuario existe y está activo
    IF EXISTS (SELECT * FROM USUARIOS WHERE usuario = @Usuario AND estado = 1)
    BEGIN
        -- Verificar si la contraseña es correcta
        IF EXISTS (SELECT * FROM USUARIOS WHERE usuario = @Usuario AND contrasena = @Clave AND estado = 1)
        BEGIN
            SET @IdUsuario = (SELECT TOP 1 id_usuario FROM USUARIOS WHERE usuario = @Usuario AND contrasena = @Clave AND estado = 1)
            SET @Mensaje = 'Inicio de sesión exitoso'
        END
        ELSE
        BEGIN
            SET @Mensaje = 'Contraseña incorrecta'
        END
    END
    ELSE
    BEGIN
        SET @Mensaje = 'El usuario no existe o está inactivo'
    END
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (2) PROCEDIMIENTO ALMACENADO PARA OBTENER EL DETALLE DE UN USUARIO
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
--------------------------------------------------------------------------------------------------------------------

-- (3) PROCEDIMIENTO ALMACENADO PARA OBTENER LOS PERMISOS DE UN ROL
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
--------------------------------------------------------------------------------------------------------------------

-- (4) PROCEDIMIENTO ALMACENADO PARA ACTUALIZAR LOS PERMISOS DE UN ROL
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
--------------------------------------------------------------------------------------------------------------------

-- (5) PROCEDIMIENTO ALMACENADO PARA OBTENER TODOS LOS USUARIOS
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
--------------------------------------------------------------------------------------------------------------------

-- (6) PROCEDIMIENTO ALMACENADO PARA REGISTRAR UN NUEVO USUARIO
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
        SET @Mensaje = 'El nombre de usuario ya está en uso'
        RETURN
    END

    -- Verificar si el correo electrónico ya existe
    IF EXISTS (SELECT * FROM USUARIOS WHERE correo = @Correo)
    BEGIN
        SET @Mensaje = 'El correo electrónico ya está registrado'
        RETURN
    END

    -- Insertar el nuevo usuario
    INSERT INTO USUARIOS (pri_nombre, seg_nombre, pri_apellido, seg_apellido, usuario, contrasena, correo, telefono, fk_rol, estado)
    VALUES (@PriNombre, @SegNombre, @PriApellido, @SegApellido, @Usuario, CONVERT(VARBINARY(64), @Clave), @Correo, @Telefono, @FkRol, @Estado)

    SET @Resultado = SCOPE_IDENTITY()
    SET @Mensaje = 'Usuario registrado exitosamente'
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (7) PROCEDIMIENTO ALMACENADO PARA MODIFICAR LOS DATOS DE UN USUARIO
CREATE PROCEDURE usp_ModificarUsuario
    @IdUsuario INT,
    @PriNombre VARCHAR(60),
    @SegNombre VARCHAR(60),
    @PriApellido VARCHAR(60),
    @SegApellido VARCHAR(60),
    @Usuario VARCHAR(50),    
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
        SET @Mensaje = 'El nombre de usuario ya está en uso'
        RETURN
    END

    -- Verificar si el correo electrónico ya existe (excluyendo al usuario actual)
    IF EXISTS (SELECT 1 FROM USUARIOS WHERE correo = @Correo AND id_usuario != @IdUsuario)
    BEGIN
        SET @Mensaje = 'El correo electrónico ya está registrado'
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
        correo = @Correo,
        telefono = @Telefono,
        fk_rol = @FkRol,
        estado = @Estado
    WHERE id_usuario = @IdUsuario

    SET @Resultado = 1
    SET @Mensaje = 'Usuario actualizado exitosamente'
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (8) PROCEDIMIENTO ALMACENADO PARA MODIFICAR LA CONTRASEÑA DE UN USUARIO
CREATE PROCEDURE usp_ModificarContrasena
    @IdUsuario INT,    
    @ClaveActual VARCHAR(100),
    @ClaveNueva VARCHAR(100),
    
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

    -- Verificar si la contraseña actual es correcta
    IF NOT EXISTS (SELECT 1 FROM USUARIOS WHERE id_usuario = @IdUsuario AND contrasena = CONVERT(VARBINARY(64), @ClaveActual))
    BEGIN
        SET @Mensaje = 'La contraseña actual es incorrecta'
        RETURN
    END

    -- Actualizar la contraseña
    UPDATE USUARIOS
    SET contrasena = CONVERT(VARBINARY(64), @ClaveNueva)
    WHERE id_usuario = @IdUsuario

    SET @Resultado = 1
    SET @Mensaje = 'Usuario actualizado exitosamente'
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (9) PROCEDIMIENTO ALMACENADO PARA ELIMINAR UN USUARIO
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
--------------------------------------------------------------------------------------------------------------------

-- (10) PROCEDIMIENTO ALMACENADO PARA OBTENER TODOS LOS ROLES
CREATE PROCEDURE usp_ObtenerRoles
AS
BEGIN
    SELECT id_rol, descripcion, estado FROM ROL
END
GO
--------------------------------------------------------------------------------------------------------------------

-- (11) PROCEDIMIENTO ALMACENADO PARA REGISTRAR UN NUEVO ROL
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
--------------------------------------------------------------------------------------------------------------------

-- (12) PROCEDIMIENTO ALMACENADO PARA MODIFICAR LOS DATOS DE UN ROL
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
--------------------------------------------------------------------------------------------------------------------

-- (13) PROCEDIMIENTO ALMACENADO PARA ELIMINAR UN ROL
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
--------------------------------------------------------------------------------------------------------------------