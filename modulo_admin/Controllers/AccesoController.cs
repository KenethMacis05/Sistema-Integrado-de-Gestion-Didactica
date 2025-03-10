using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace modulo_admin.Controllers
{
    public class AccesoController : Controller
    {
        // GET: Acceso
        [HttpGet]
        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Index(string usuario, string password)
        {
            if (usuario == "admin" && password == "admin")
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                ViewBag.Mensaje = "Usuario o contraseña incorrectos";
                return View();
            }
        }
    }
}