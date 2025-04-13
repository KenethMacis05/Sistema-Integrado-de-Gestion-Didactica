using capa_entidad;
using capa_negocio;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace modulo_admin.Controllers
{
    public class RolController : Controller
    {
        CN_Rol CN_Rol = new CN_Rol();

        // GET: Rol
        public ActionResult Index()
        {
            return View();
        }

        // Metodo para listar los usuarios
        [HttpGet]
        public JsonResult ListarRoles()
        {
            List<ROL> lst = new List<ROL>();
            lst = CN_Rol.Listar();

            return Json(new { data = lst }, JsonRequestBehavior.AllowGet);
        }
    }
}