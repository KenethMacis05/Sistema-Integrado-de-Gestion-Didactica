using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using capa_negocio;
using capa_entidad;
using modulo_admin.Filters;
using modulo_admin.Controllers;
using System.Diagnostics;

namespace modulo_admin.Controllers
{
    [VerificarSession]
    public class HomeController : Controller
    {
        private static USUARIOS SesionUsuario;
        public ActionResult Index()
        {           
            return View();
        }        
        
        public ActionResult CerrarSesion()
        {
            Session["UsuarioAutenticado"] = null;
            Session["RolUsuario"] = null;
            Session.Clear();
            Session.Abandon();
            return RedirectToAction("Index", "Acceso");
        }
    }
}