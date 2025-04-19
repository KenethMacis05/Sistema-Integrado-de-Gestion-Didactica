using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using capa_datos;
using capa_entidad;

namespace capa_negocio
{
    public class CN_Carpeta
    {
        private CD_Carpeta CD_Carpeta = new CD_Carpeta();

        public List<CARPETA> ListarCarpeta(int id_usuario, out int resultado, out string mensaje)
        {
            return CD_Carpeta.Listar(id_usuario, out resultado, out mensaje);
        }

        public int Crear(CARPETA carpeta, out string mensaje)
        {
            mensaje = string.Empty;
            if (string.IsNullOrEmpty(carpeta.nombre))
            {
                mensaje = "Por favor, ingrese el nombre de la carpeta";
            }

            return CD_Carpeta.CrearCarpeta(carpeta, out mensaje);
        }

        public int Editar(CARPETA carpeta, out string mensaje)
        {
            mensaje = string.Empty;

            if (string.IsNullOrEmpty(carpeta.nombre))
            {
                mensaje = "Por favor, ingrese el nombre de la carpeta";
                return 0;
            }

            bool actualizado = CD_Carpeta.ActualizarCarpeta(carpeta, out mensaje);
            return actualizado ? 1 : 0;
        }


        public int Eliminar(int id_carpeta, out string mensaje)
        {
            bool eliminado = CD_Carpeta.EliminarCarpeta(id_carpeta, out mensaje);
            return eliminado ? 1 : 0;
        }
    }
}
