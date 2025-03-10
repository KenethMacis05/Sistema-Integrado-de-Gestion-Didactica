using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace modulo_admin.Controllers
{
    public class PlanificacionController : Controller
    {
        // GET: Planificacion
        public ActionResult Matriz_de_Integracion()
        {
            return View();
        }public ActionResult Plan_Didactico_Semestral()
        {
            return View();
        }public ActionResult Plan_de_Clases_Diario()
        {
            return View();
        }
    }
}