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

        public ActionResult GestionArchivos()
        {
            return View();
        }
       
        [HttpGet]
        public JsonResult ListarCarpetas()
        {
            USUARIOS usuario = (USUARIOS)Session["UsuarioAutenticado"];
            int resultado;
            string mensaje;

            List<CARPETA> lst = new List<CARPETA>();
            lst = CN_Carpeta.ListarCarpeta(usuario.id_usuario, out resultado, out mensaje);

            return Json(new { data = lst, resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        // Metodo para Guardar carpetas        
        [HttpPost]
        public JsonResult GuardarCarpeta(CARPETA carpeta)
        {            
            carpeta.fk_id_usuario = (int)Session["IdUsuario"];

            string mensaje = string.Empty;
            int resultado = 0;

            if (carpeta.id_carpeta == 0)
            {
                // Crear nueva carpeta
                resultado = CN_Carpeta.Crear(carpeta, out mensaje);
            }
            else
            {
                // Editar usuario existente
                resultado = CN_Carpeta.Editar(carpeta, out mensaje);
            }

            return Json(new { Resultado = resultado, Mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        // Metodo para Borrar carpetas
        [HttpPost]
        public JsonResult EliminarCarpeta(int id_carpeta)
        {
            string mensaje = string.Empty;

            int resultado = CN_Carpeta.Eliminar(id_carpeta, out mensaje);

            return Json(new { Respuesta = (resultado == 1), Mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

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