using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Services.Description;
using capa_datos;
using capa_entidad;
using capa_negocio;
using modulo_admin.Filters;

namespace modulo_admin.Controllers
{
    [VerificarSession]
    public class AccesoController : Controller
    {
        private CD_Usuarios CD_Usuarios = new CD_Usuarios();
        // GET: Acceso  
        [HttpGet]
        public ActionResult Index(int? error)
        {
            return View();
        }

        [HttpGet]
        public ActionResult Reestablecer()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult Reestablecer(string passwordActual, string nuevaPassword, string confirmarPassword)
        {         
            try
            {
                if (string.IsNullOrEmpty(Session["IdUsuario"]?.ToString()))
                {
                    return Json(new { success = false, message = "Sesión no válida" });
                }

                int idUsuario = Convert.ToInt32(Session["IdUsuario"]);

                if (nuevaPassword != confirmarPassword)
                {
                    return Json(new { success = false, message = "Las contraseñas no coinciden" });
                }

                // Encriptar contraseñas
                string contrasenaActualHash = Encriptar.GetSHA256(passwordActual);
                string nuevaContraseñaHash = Encriptar.GetSHA256(nuevaPassword);

                // Llamar al método de capa de datos
                int resultado = CD_Usuarios.ReestablecerContrasena(
                    idUsuario,
                    contrasenaActualHash,
                    nuevaContraseñaHash,
                    out string mensaje
                );

                if (resultado == 1)
                {
                    // Actualizar sesión
                    var usuarioActualizado = CD_Usuarios.ObtenerUsuarioPorId(idUsuario);
                    Session["UsuarioAutenticado"] = usuarioActualizado;

                    return Json(new { success = true });
                }

                return Json(new { success = false, message = mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Error: " + ex.Message });
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Index(string usuario, string password)
        {
            try
            {
                string mensaje = string.Empty;
                //Generar hash de la contraseña  
                string contrasenaHash = Encriptar.GetSHA256(password);

                //Validar usuario y contraseña  
                USUARIOS usuarioAutenticado = CD_Usuarios.LoginUsuario(usuario, contrasenaHash, out mensaje);
                if (usuarioAutenticado != null)
                {
                    Session["UsuarioAutenticado"] = usuarioAutenticado;
                    Session["RolUsuario"] = usuarioAutenticado.fk_rol;
                    Session["IdUsuario"] = usuarioAutenticado.id_usuario;
                    Session.Timeout = 30;
                    if (usuarioAutenticado.reestablecer)
                    {
                        return RedirectToAction("Reestablecer", "Acceso");
                    }
                    else
                    {
                        return RedirectToAction("Index", "Home");
                    }
                }
                else
                {
                    TempData["ErrorMessage"] = mensaje ?? "Credenciales incorrectas";
                    return RedirectToAction("Index", "Acceso");
                }
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Error al iniciar sesión: " + ex.Message;
                return RedirectToAction("Index", "Acceso");
            }
        }
    }
}