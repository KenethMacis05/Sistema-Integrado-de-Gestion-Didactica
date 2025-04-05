using capa_entidad;
using capa_negocio;
using modulo_admin.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Services.Description;

namespace modulo_admin.Controllers
{
    [VerificarSession]
    public class ArchivoController : Controller
    {     
        CN_Carpeta CN_Carpeta = new CN_Carpeta();

        #region Carpetas

        // Vista a la vista de Gestion de Archivos
        public ActionResult GestionArchivos()
        {
            return View();
        }

        // Metodo para Listar los usuarios
        [HttpGet]
        public JsonResult ListarCarpetas(int id_usuario)
        {
 
            List<CARPETA> lst = new List<CARPETA>();
            lst = CN_Carpeta.ListarCarpeta(id_usuario);

            return Json(new { data = lst }, JsonRequestBehavior.AllowGet);
        }

        // Metodo para Guardar carpetas


        // Metodo para Borrar carpetas

        #endregion


        public ActionResult CarpetasCompartidas()
        {
            return View();
        }
        public ActionResult ArchivosCompartidos()
        {
            return View();
        }
    }
}