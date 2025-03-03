<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="modulo_admin.Login" %>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - SIGI</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Estilos personalizados -->
    <style>
        body {
            background-color: #f8f9fa;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 1rem;
        }

        .contenedorLogin {
            background-color: #fff;
            border-radius: 0.625rem;
            box-shadow: 0 0 0.625rem rgba(0, 0, 0, 0.1);
            padding: 2rem;
        }

        .login-image {
            width: 100%;
            height: auto;
            border-top-left-radius: 0.625rem;
            border-bottom-left-radius: 0.625rem;
        }

        .cart {
            border-radius: 0.625rem;
            box-shadow: 0 0 0.625rem rgba(0, 0, 0, 0.1);
        }

        .input-wrapper {
            display: flex;
            align-items: center;
            background-color: #f4f4f4;
            border-radius: 5px;
            border: 1px solid #ddd;
            overflow: hidden;
            transition: border-color 0.3s ease-in-out;
        }

        .input-wrapper input {
            flex: 1;
            border: none;
            background: none;
            padding: 10px;
            font-size: 14px;
            outline: none;
            color: #333;
        }

        .input-wrapper .icon {
            background-color: #0a1f5e;
            padding: 7px 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 3px;
            color: white;
            cursor: pointer;
        }

        .input-wrapper:focus-within {
            border: 1px solid #0072BB;
            box-shadow: 0px 0px 5px rgba(0, 115, 187, 0.658);
        }

        .input-wrapper:focus-within .icon {
            background-color: #0072BB;
        }
    </style>
</head>

<body>
    <div class="container">
        <div class="row cart">
            <div class="col-lg-7 d-none d-lg-block p-0">
                <!-- Imagen responsiva para pantallas grandes -->
                <picture>
                    <source srcset="assets/img/loginIMG1920x180-711x682.png" media="(min-width: 768px)">
                    <source srcset="assets/img/loginIMG1920x180-711x682.png" media="(min-width: 1920px)">
                    <source srcset="assets/img/loginIMG1920x180-711x682.png" media="(min-width: 1200px)">
                    <img src="assets/img/loginIMG1920x180-711x682.png" alt="2025: Eficiencia y Calidad para seguir en Victorias"
                        class="login-image">
                </picture>
            </div>
            <div class="col-lg-5 p-5 contenedorLogin">
                <div class="login-header text-center mb-4">
                    <h1 class="fw-bold">INICIAR SESIÓN</h1>
                    <p class="text-muted">Ingrese sus credenciales para acceder</p>
                </div>
                <form>
                    <div class="mb-3">
                        <label for="username" class="form-label">Usuario :</label>
                        <div class="input-wrapper">
                            <input type="text" id="username" class="border-0 shadow-none"
                                placeholder="Ingrese su nombre de usuario">
                            <span class="icon">
                                <i class="bi bi-person-fill fs-5"></i>
                            </span>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="password" class="form-label">Contraseña:</label>
                        <div class="input-wrapper">
                            <input type="password" id="password" class="border-0 shadow-none" placeholder="Ingrese su contraseña">
                            <span class="icon" id="togglePassword">
                                <i class="bi bi-key-fill fs-5"></i>
                            </span>
                        </div>
                    </div>
                    <div class="mb-3 form-check">
                        <input type="checkbox" class="form-check-input" id="rememberMe">
                        <label class="form-check-label" for="rememberMe">¿Olvidó su contraseña?</label>
                    </div>
                    <button type="submit" class="btn btn-primary w-100" style="background-color: #0072BB;">Iniciar
                        Sesión</button>
                    <div class="my-3 d-flex align-items-center">
                        <div class="flex-grow-1 bg-secondary" style="height: 1.5px;"></div>
                        <div class="mx-3">o</div>
                        <div class="flex-grow-1 bg-secondary" style="height: 1.5px;"></div>
                    </div>
                    <button type="submit" class="btn btn-outline-primary w-100" style="border-color: #02116F; color: #02116F;">
                        Iniciar Sesión por Correo Institucional
                    </button>
                </form>
            </div>
        </div>
    </div>
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL"
        crossorigin="anonymous"></script>
    <!-- Script para mostrar/ocultar contraseña -->
    <script>
        const togglePassword = document.getElementById('togglePassword');
        const passwordInput = document.getElementById('password');

        togglePassword.addEventListener('click', function () {
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);

            // Cambiar el ícono
            if (type === 'password') {
                togglePassword.innerHTML = '<i class="bi bi-key-fill fs-5"></i>';
            } else {
                togglePassword.innerHTML = '<i class="bi bi-eye-slash fs-5"></i>';
            }
        });

        // Cambiar el ícono al hacer focus en el input de contraseña
        passwordInput.addEventListener('focus', function () {
            togglePassword.innerHTML = '<i class="bi bi-eye-fill fs-5"></i>';
        });

        // Cambiar el ícono al perder el focus si la contraseña está oculta
        passwordInput.addEventListener('blur', function () {
            if (passwordInput.getAttribute('type') === 'password') {
                togglePassword.innerHTML = '<i class="bi bi-key-fill fs-5"></i>';
            }
        });
    </script>
</body>

</html>
