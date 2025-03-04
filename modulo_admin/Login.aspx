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

        .toggle-password {
            cursor: pointer;
            color: #0072BB;
            text-decoration: underline;
        }

        .btnLogin {
            box-shadow: -3px 3px 10px rgb(128, 128, 128, 0.658);
        }

            .btnLogin:hover {
                background-color: #0283D5 !important;
            }

            .btnLogin:active {
                background-color: #025E99 !important;
            }

        @media (max-width: 768px){
            .separador{
                margin: 1rem 0px !important;
            }
            .contenedorLogin{
                padding: 3rem 1rem !important
            }
        }
        .btnLoginCorreoInstitucional:hover{
            background: #F4F4F4;
            border-color: #0072BB !important;
            color: #0072BB !important;
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
                    <h1 class="fw-bold fs-2" style="color: #555555">INICIAR SESIÓN</h1>
                    <p class="text-muted">Ingrese sus credenciales para acceder</p>
                </div>
                <form>
                    <div class="mb-3">
                        <label for="username" class="form-label" style="color: #555555">Usuario</label>
                        <div class="input-wrapper">
                            <input type="text" id="username" required class="border-0 shadow-none" placeholder="Ingrese su nombre de usuario">
                            <span class="icon">
                                <i class="bi bi-person-fill fs-5"></i>
                            </span>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="password" class="form-label" style="color: #555555">Contraseña:</label>
                        <div class="input-wrapper">
                            <input type="password" id="password" required class="border-0 shadow-none" placeholder="Ingrese su contraseña">
                            <span class="icon" id="togglePassword">
                                <i class="bi bi-key-fill fs-5"></i>
                            </span>
                        </div>
                        <p class="mt-2 toggle-password" id="togglePasswordText">Ver contraseña</p>
                    </div>
                    <div class="mb-5 form-check text-end">
                        <a class="" href="#" style="color: #02116F">¿Olvidó su contraseña?</a>
                    </div>
                    <button type="submit" class="btn btn-primary w-100 fw-bold btnLogin" style="background-color: #0072BB;">
                        Iniciar
                        Sesión</button>
                    <div class="mt-5 mb-5 separador d-flex align-items-center">
                        <div class="flex-grow-1" style="height: 1.5px; background-color: #C2C2C2"></div>
                        <div class="mx-3" style="color: #C2C2C2">O</div>
                        <div class="flex-grow-1" style="height: 1.5px; background-color: #C2C2C2"></div>
                    </div>
                    <button type="submit" class="btn btn-outline-primary w-100 btnLoginCorreoInstitucional" style="border-color: #02116F; color: #02116F;">
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
        const togglePasswordText = document.getElementById('togglePasswordText');
        const passwordInput = document.getElementById('password');
        const togglePasswordIcon = document.getElementById('togglePassword');

        togglePasswordText.addEventListener('click', function () {
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);

            // Cambiar el texto y el ícono
            if (type === 'password') {
                togglePasswordText.textContent = 'Ver contraseña';
                togglePasswordIcon.innerHTML = '<i class="bi bi-key-fill fs-5"></i>';
            } else {
                togglePasswordText.textContent = 'Ocultar contraseña';
                togglePasswordIcon.innerHTML = '<i class="bi bi-eye-slash fs-5"></i>';
            }
        });

        // Cambiar el ícono al hacer focus en el input de contraseña
        passwordInput.addEventListener('focus', function () {
            togglePasswordIcon.innerHTML = '<i class="bi bi-eye-fill fs-5"></i>';
        });

        // Cambiar el ícono al perder el focus si la contraseña está oculta
        passwordInput.addEventListener('blur', function () {
            if (passwordInput.getAttribute('type') === 'password') {
                togglePasswordIcon.innerHTML = '<i class="bi bi-key-fill fs-5"></i>';
            }
        });
    </script>
</body>

</html>
