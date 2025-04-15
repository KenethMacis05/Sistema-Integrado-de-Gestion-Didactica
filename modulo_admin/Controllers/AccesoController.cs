using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Services.Description;
using capa_datos;
using capa_entidad;
using capa_negocio;

namespace modulo_admin.Controllers
{
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
        public ActionResult Reestablecer(string passwordActual, string nuevaPassword, string confirmarPassword)
        {
            try
            {
                int idUsuario = Convert.ToInt32(Session["idUsuario"]);
                string mensaje = string.Empty;
                int resultado = 0;
                string contrasenaActualHash = Encriptar.GetSHA256(passwordActual);
                if (nuevaPassword == confirmarPassword)
                {
                    string nuevaContraseñaHash = Encriptar.GetSHA256(nuevaPassword);

                    resultado = CD_Usuarios.ActualizarContrasena(idUsuario, contrasenaActualHash, nuevaContraseñaHash, out mensaje);

                }
            }
            catch (Exception)
            {

                throw;
            }
            return ViewBag.Mensaje = "Hola";
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