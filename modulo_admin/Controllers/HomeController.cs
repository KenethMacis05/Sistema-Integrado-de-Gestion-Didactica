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

        public ActionResult Index()
        {


            if (Session["UsuarioAutenticado"] != null)
            {
                SesionUsuario = (USUARIOS)Session["UsuarioAutenticado"];
            }
            else
            {
                SesionUsuario = new USUARIOS();
            }

            try
            {                
                ViewBag.NombreUsuario = SesionUsuario.pri_nombre + " " + SesionUsuario.pri_apellido;                
            }
            catch (Exception)
            {                                
                ViewBag.Mensaje = "Ocurrió un error al cargar los datos del usuario";
                return View();
            }

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
            lst = new CN_Usuario().Listar();

            return Json(new { data = lst}, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult GuardarUsuario(USUARIOS usuario)
        {
            Object resultado;
            string mensaje = string.Empty;            

            if (usuario.id_usuario == 0)
            {
                resultado = new CD_Usuarios().RegistrarUsuario(usuario, out mensaje);
            }
            else
            {
                resultado = new CD_Usuarios().ActualizarUsuario(usuario, out mensaje);
            }
            return Json(new { Resultado = resultado, Mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult EliminarUsuario(int id_usuario)
        {
            bool respuesta = false;
            string mensaje = string.Empty;

            respuesta = new CD_Usuarios().EliminarUsuario(id_usuario, out mensaje);
            
            return Json(new { Respuesta = respuesta, Mensaje = mensaje }, JsonRequestBehavior.AllowGet);
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