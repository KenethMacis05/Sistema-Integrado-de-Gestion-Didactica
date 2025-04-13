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
            List<PERMISOS> lst = new List<PERMISOS>();
            lst = CN_Permisos.ListarPermisosPorRol(IdRol);

            return Json(new { data = lst }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult ObtenerPermisosNoAsignados(int IdRol)
        {            
            List<CONTROLLER> lst = new List<CONTROLLER>();
            lst = CN_Permisos.ListarPermisosNoAsignados(IdRol);

            return Json(new { data = lst }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult AsignarPermisos(int IdRol, List<int> IdsControladores)
        {
            try
            {
                var cnPermisos = new CN_Permisos();
                var resultados = cnPermisos.AsignarPermisos(IdRol, IdsControladores);

                var data = resultados.Select(r => new {
                    IdControlador = r.Key,
                    Codigo = r.Value.Codigo,
                    Mensaje = r.Value.Mensaje,
                    EsExitoso = r.Value.Codigo > 0
                }).ToList();

                return Json(new
                {
                    success = true,
                    data = data,
                    totalExitosos = data.Count(d => d.EsExitoso),
                    totalFallidos = data.Count(d => !d.EsExitoso)
                });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }

        [HttpPost]
        public JsonResult EliminarPermiso(int idRol, int idPermiso)
        {
            return Json(new { success = false, message = "Método no implementado" });
        }

    }
}