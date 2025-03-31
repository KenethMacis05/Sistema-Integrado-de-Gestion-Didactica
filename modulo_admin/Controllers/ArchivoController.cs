using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace modulo_admin.Controllers
{
    public class ArchivoController : Controller
    {
        // GET: Archivo
        public ActionResult GestionArchivos()
        {
            return View();
        }public ActionResult CarpetasCompartidas()
        {
            return View();
        }public ActionResult ArchivosCompartidos()
        {
            return View();
        }
    }
}