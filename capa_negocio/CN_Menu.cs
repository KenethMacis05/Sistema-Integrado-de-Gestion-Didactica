using capa_datos;
using capa_entidad;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace capa_negocio
{
    public class CN_Menu
    {
        private CD_Menu CD_Menu = new CD_Menu();

        public List<MENU> ListarMenuPorUsuario(int IdUsuario)
        {
            try
            {
                return CD_Menu.ObtenerMenuPorUsuario(IdUsuario);           

            }
            catch (Exception ex)
            {
                throw new Exception($"Error al obtener menú: {ex.Message}");
            }
        }
    }
}
