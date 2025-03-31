select * from USUARIOS;

-- Registrar Usuario
DECLARE @Resultado INT
DECLARE @Mensaje VARCHAR(255)

EXEC usp_RegistrarUsuario
    @PriNombre = 'Juan',
    @SegNombre = 'Carlos',
    @PriApellido = 'Pérez',
    @SegApellido = 'Gómez',
    @Usuario = 'juanperez',
    @Clave = '12345',
    @Correo = 'juan.perez@example.com',
    @FkRol = 1,
    @Estado = 1,
    @Resultado = @Resultado OUTPUT,
    @Mensaje = @Mensaje OUTPUT

SELECT @Resultado AS Resultado, @Mensaje AS Mensaje

-- Editar Usuario
DECLARE @Resultado INT
DECLARE @Mensaje VARCHAR(255)

EXEC usp_ModificarUsuario
    @IdUsuario = 3, -- Asegúrate de usar un ID válido
    @PriNombre = 'Ana',
    @SegNombre = 'María',
    @PriApellido = 'López',
    @SegApellido = 'García',
    @Usuario = 'ana.lopez',
    @Clave = 'nueva_clave',
    @Correo = 'ana.lopez@example.com',
    @FkRol = 2,
    @Estado = 1, -- Activo (1) o Inactivo (0)
    @Resultado = @Resultado OUTPUT,
    @Mensaje = @Mensaje OUTPUT

SELECT @Resultado AS Resultado, @Mensaje AS Mensaje
SELECT * FROM USUARIOS WHERE id_usuario = 3

-- Elimanar usuario
DECLARE @Resultado BIT

EXEC usp_EliminarUsuario
    @IdUsuario = 6,
    @Resultado = @Resultado OUTPUT

SELECT @Resultado AS Resultado

---Usuario login
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