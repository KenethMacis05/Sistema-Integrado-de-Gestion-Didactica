using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using capa_negocio;
using capa_entidad;

namespace modulo_admin.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            var usuario = Session["UsuarioAutenticado"] as USUARIOS;            
            return View();
        }public ActionResult Usuario()
        {
            return View();
        }public ActionResult Categoria()
        {
            return View();
        }
        public ActionResult Marca()
        {
            return View();
        }
        public ActionResult Producto()
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
    }
}