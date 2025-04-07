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

        // Metodo para Listar las carpetas
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

        #region CarpetasCompartidas

        // Vista a la vista de Carpetas Compartidas
        public ActionResult CarpetasCompartidas()
        {
            return View();
        }

        // Metodo para Listar las carpetas compartidas

        // Metodo para Guardar carpetas compartidas

        // Metodo para Borrar carpetas compartidas

        #endregion

        #region Archivos


        // Metodo para Listar las carpetas

        // Metodo para Guardar carpetas

        // Metodo para Borrar carpetas

        #endregion

        #region ArchivosCompartidos
        // Vista a la vista de Archivos Compartidos
        public ActionResult ArchivosCompartidos()
        {
            return View();
        }

        // Metodo para Listar los archivos compartidos

        // Metodo para Guardar archivos compartidos

        // Metodo para Borrar archivos compartidos
        #endregion
    }
}