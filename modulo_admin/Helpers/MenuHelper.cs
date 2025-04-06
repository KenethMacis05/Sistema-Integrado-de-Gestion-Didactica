using capa_entidad;
using System;
using System.Collections.Generic;
using System.Text;
using System.Web.Mvc;
using capa_negocio;

namespace modulo_admin.Helpers
{
    public static class MenuHelper
    {

        public static MvcHtmlString GenerarMenu(this HtmlHelper html)
        {
            // Obtener el idUsuario desde ViewBag
            var viewBag = html.ViewContext.Controller.ViewBag;
            int? idUsuario = viewBag.idUsuario as int?;

            if (!idUsuario.HasValue)
            {
                return new MvcHtmlString("");
            }            

            // Obtener permisos del usuario
            CN_Permisos CN_Permisos = new CN_Permisos();
            List<MENU> permisos = CN_Permisos.ListarPermisosPorUsuario(idUsuario.Value);

            if (permisos == null || permisos.Count == 0)
                return new MvcHtmlString("");
           
            var sb = new StringBuilder();            

            foreach (var menu in permisos)
            {
                sb.Append($@"                            
                           <a class='nav-link esp-link esp-link-hover' href='/{menu.controlador}/{menu.vista}'>
                               <div class='sb-nav-link-icon'>
                                   <i class='{menu.icono}'></i>
                               </div>
                                   {menu.nombre}
                           </a>"                            
                 );
            }
            
            return new MvcHtmlString(sb.ToString());
        }

    }
}
