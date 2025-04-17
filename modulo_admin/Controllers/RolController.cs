using capa_entidad;
using capa_negocio;
using modulo_admin.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace modulo_admin.Controllers
{
    [VerificarSession]
    public class RolController : Controller
    {
        CN_Rol CN_Rol = new CN_Rol();

        // GET: Rol
        public ActionResult Index()
        {
            return View();
        }

        // Metodo para listar los roles
        [HttpGet]
        public JsonResult ListarRoles()
        {
            List<ROL> lst = new List<ROL>();
            lst = CN_Rol.Listar();

            return Json(new { data = lst }, JsonRequestBehavior.AllowGet);
        }

        // Metodo para crear o editar roles
        [HttpPost]
        public JsonResult GuardarRol(ROL rol)
        {
            string mensaje = string.Empty;
            int resultado = 0;

            if (rol.id_rol == 0)
            {             
                resultado = CN_Rol.Crear(rol, out mensaje);
            }
            else
            {                
                resultado = CN_Rol.Editar(rol, out mensaje);
            }

            return Json(new { Resultado = resultado, Mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        // Metodo para borrar roles
        [HttpPost]
        public JsonResult EliminarRol(int id_rol)
        {
            string mensaje = string.Empty;

            int resultado = CN_Rol.Eliminar(id_rol, out mensaje);

            return Json(new { Respuesta = (resultado == 1), Mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }
    }
}