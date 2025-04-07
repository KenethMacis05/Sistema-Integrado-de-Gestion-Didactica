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
    public class MenuController : Controller
    {
        CN_Menu CN_Menu = new CN_Menu();        

        // Metodo para listar los menus
        [HttpGet]
        public JsonResult ListarMenu()
        {
            List<MENU> lst = new List<MENU>();
            lst = CN_Menu.ListarMenuPorUsuario(1);

            return Json(new { data = lst }, JsonRequestBehavior.AllowGet);
        }

        // Metodo para Guardar los menus
        [HttpPost]
        public JsonResult GuardarMenu(MENU menu)
        {
            string mensaje = string.Empty;
            int resultado = 0;
            if (menu.id_menu == 0)
            {
                // Crear nuevo menu
                resultado = CN_Menu.Registra(menu, out mensaje);
            }
            else
            {
                // Editar menu existente
                resultado = CN_Menu.Editar(menu, out mensaje);
            }
            return Json(new { Resultado = resultado, Mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        // Metodo para borrar menus
        [HttpPost]
        public JsonResult EliminarMenu(int id_menu)
        {
            string mensaje = string.Empty;
            int resultado = CN_Menu.Eliminar(id_menu, out mensaje);
            return Json(new { Respuesta = (resultado == 1), Mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }
    }
}