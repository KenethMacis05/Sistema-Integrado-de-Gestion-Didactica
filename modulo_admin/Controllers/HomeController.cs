using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using capa_negocio;
using capa_entidad;
using modulo_admin.Filters;
using modulo_admin.Controllers;
using capa_datos;

namespace modulo_admin.Controllers
{
    [VerificarSession]
    public class HomeController : Controller
    {
        private static USUARIOS SesionUsuario;

        public ActionResult Index()
        {


            if (Session["UsuarioAutenticado"] != null)
            {
                SesionUsuario = (USUARIOS)Session["UsuarioAutenticado"];
            }
            else
            {
                SesionUsuario = new USUARIOS();
            }

            try
            {                
                ViewBag.NombreUsuario = SesionUsuario.pri_nombre + " " + SesionUsuario.pri_apellido;                
            }
            catch (Exception ex)
            {                                
                ViewBag.Mensaje = "Ocurrió un error al cargar los datos del usuario";
                return View();
            }

            return View();
        }
        
        public ActionResult Usuario()
        {
            return View();
        }               

        [HttpGet]
        public JsonResult ListarUsuarios()
        {
            List<USUARIOS> lst = new List<USUARIOS>();
            lst = new CN_Usuario().Listar();

            return Json(new { data = lst}, JsonRequestBehavior.AllowGet);
        }

        public ActionResult CerrarSesion()
        {
            Session["UsuarioAutenticado"] = null;            
            return RedirectToAction("Index", "Acceso");
        }
    }
}