using capa_datos;
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
    public class PermisosController : Controller
    {

        private readonly CN_Permisos CN_Permisos = new CN_Permisos();

        // GET: Permisos  
        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public JsonResult ObtenerPermisosPorRol(int IdRol)
        {
            string mensaje = string.Empty;

            List<PERMISOS> lst = new List<PERMISOS>();
            lst = CN_Permisos.ListarPermisosPorRol(IdRol, out mensaje);

            return Json(new { data = lst, mensaje }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult ObtenerPermisosNoAsignados(int IdRol)
        {
            string mensaje = string.Empty;

            List<CONTROLLER> lst = new List<CONTROLLER>();
            lst = CN_Permisos.ListarPermisosNoAsignados(IdRol, out mensaje);

            return Json(new { data = lst, mensaje }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult AsignarPermisos(int idRol, List<int> permisos)
        {
            bool resultado = true;
            foreach (var idControlador in permisos)
            {
                if (!CN_Permisos.AsignarPermiso(idRol, idControlador, true))
                    resultado = false;
            }
            return Json(new { success = resultado });
        }

        [HttpPost]
        public JsonResult EliminarPermiso(int idRol, int idPermiso)
        {
            // Implementar lógica para eliminar permiso (actualizar estado a false)
            bool resultado = CN_Permisos.AsignarPermiso(idRol, idPermiso, false);
            return Json(new { success = resultado });
        }

    }
}