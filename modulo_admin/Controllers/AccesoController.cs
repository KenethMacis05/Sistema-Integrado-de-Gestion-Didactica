using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using capa_datos;
using capa_entidad;

namespace modulo_admin.Controllers
{
    public class AccesoController : Controller
    {
        private CD_Usuarios cd_usuario = new CD_Usuarios();
        // GET: Acceso
        [HttpGet]
        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Index(string usuario, string password)
        {
            try
            {
                //Validar que los campos no esten vacios
                if (string.IsNullOrEmpty(usuario) || string.IsNullOrEmpty(password))
                {
                    TempData["ErrorMessage"] = "Por favor, complete todos los campos.";
                    return View();
                }

                //Generar hash de la contraseña
                string contrasenaHash = Encriptar.GetSHA256(password);


                //Validar usuario y contraseña
                USUARIOS usuarioAutenticado = cd_usuario.LoginUsuario(usuario, password);
                if (usuarioAutenticado != null)
                {
                    Session["UsuarioAutenticado"] = usuarioAutenticado;

                    return RedirectToAction("Index", "Home");
                }
                else
                {
                    ViewBag.Mensaje = "Usuario o contraseña incorrectos";
                    return View();
                }
            }
            catch(Exception ex)
            {
                TempData["ErrorMessage"] = $"Error: {ex.Message}";
                return View();
            }
            
        }
    }
}