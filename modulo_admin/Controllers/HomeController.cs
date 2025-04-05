using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using capa_negocio;
using capa_entidad;
using capa_datos;
using modulo_admin.Filters;
using modulo_admin.Controllers;
using System.Diagnostics;

namespace modulo_admin.Controllers
{
    [VerificarSession]
    public class HomeController : Controller
    {
        private static USUARIOS SesionUsuario;
        CN_Usuario CN_Usuario = new CN_Usuario();

        public ActionResult Index()
        {           
            return View();
        }

        //Usuarios
        public ActionResult Usuario()
        {
            return View();
        }

        [HttpGet]
        public JsonResult ListarUsuarios()
        {
            List<USUARIOS> lst = new List<USUARIOS>();
            lst = CN_Usuario.Listar();

            return Json(new { data = lst }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult GuardarUsuario(USUARIOS usuario)
        {
            string mensaje = string.Empty;
            int resultado = 0;

            if (usuario.id_usuario == 0)
            {
                resultado = CN_Usuario.Registra(usuario, out mensaje);
            }
            else
            {
                resultado = CN_Usuario.Editar(usuario, out mensaje);
            }

            return Json(new { Resultado = resultado, Mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult EliminarUsuario(int id_usuario)
        {
            string mensaje = string.Empty;

            int resultado = CN_Usuario.Eliminar(id_usuario, out mensaje);

            return Json(new { Respuesta = (resultado == 1), Mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult CerrarSesion()
        {
            Session["UsuarioAutenticado"] = null;
            Session.Clear();
            Session.Abandon();
            return RedirectToAction("Index", "Acceso");
        }
    }
}