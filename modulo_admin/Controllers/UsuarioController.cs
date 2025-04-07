using capa_negocio;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using capa_entidad;
using modulo_admin.Filters;

namespace modulo_admin.Controllers
{
    [VerificarSession]
    public class UsuarioController : Controller
    {
        CN_Usuario CN_Usuario = new CN_Usuario();

        // GET: Usuario
        [HttpGet]
        public ActionResult Index()
        {
            return View();
        }
        //########################################################################//

        // Metodo para listar los usuarios
        [HttpGet]
        public JsonResult ListarUsuarios()
        {
            List<USUARIOS> lst = new List<USUARIOS>();
            lst = CN_Usuario.Listar();

            return Json(new { data = lst }, JsonRequestBehavior.AllowGet);
        }
        //########################################################################//

        // Metodo para Guardar los usuarios
        [HttpPost]
        public JsonResult GuardarUsuario(USUARIOS usuario)
        {
            string mensaje = string.Empty;
            int resultado = 0;

            if (usuario.id_usuario == 0)
            {
                // Crear nuevo usuario
                resultado = CN_Usuario.Registra(usuario, out mensaje);
            }
            else
            {
                // Editar usuario existente
                resultado = CN_Usuario.Editar(usuario, out mensaje);
            }

            return Json(new { Resultado = resultado, Mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }
        //########################################################################//

        // Metodo para borrar usuarios
        [HttpPost]
        public JsonResult EliminarUsuario(int id_usuario)
        {
            string mensaje = string.Empty;

            int resultado = CN_Usuario.Eliminar(id_usuario, out mensaje);

            return Json(new { Respuesta = (resultado == 1), Mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }
    }
}