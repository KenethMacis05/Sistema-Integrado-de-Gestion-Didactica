using capa_datos;
using capa_entidad;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace capa_negocio
{
    public class CN_Permisos
    {
        private CD_Permisos CD_Permisos = new CD_Permisos();

        public bool VerificarPermiso(int IdUsuario, string controlador, string vista)
        {
            if (IdUsuario <= 0)
                return false;

            if (string.IsNullOrEmpty(controlador) || string.IsNullOrEmpty(vista))
                return false;

            try
            {
                return CD_Permisos.VerificarPermiso(IdUsuario, controlador, vista);
            }
            catch
            {
                return false;
            }
        }

        public List<PERMISOS> ListarPermisosPorRol(int IdRol)
        {
            try
            {
                return CD_Permisos.ObtenerPermisosPorRol(IdRol);
            }
            catch (Exception ex)
            {
                throw new Exception("Error al listar permisos por rol: " + ex.Message);
            }
        }

        public List<CONTROLLER> ListarPermisosNoAsignados(int IdRol)
        {
            try
            {
                return CD_Permisos.ObtenerPermisosNoAsignados(IdRol);
            }
            catch (Exception ex)
            {
                throw new Exception("Error al listar permisos no asignados: " + ex.Message);
            }
        }

        public Dictionary<int, (int Codigo, string Mensaje)> AsignarPermisos(int IdRol, List<int> IdsControladores)
        {
            var resultados = new Dictionary<int, (int, string)>();

            foreach (var idControlador in IdsControladores)
            {
                try
                {
                    int resultado = CD_Permisos.AsignarPermiso(IdRol, idControlador);
                    string mensaje = ObtenerMensajeResultado(resultado);

                    // Considerar como éxito tanto los nuevos permisos como los ya existentes
                    bool esExitoso = resultado > 0 || resultado == -2;

                    resultados.Add(idControlador, (esExitoso ? 1 : -1, mensaje));
                }
                catch (Exception ex)
                {
                    resultados.Add(idControlador, (-1, $"Error al asignar permiso: {ex.Message}"));
                }
            }

            return resultados;
        }

        private string ObtenerMensajeResultado(int codigo)
        {
            if (codigo > 0)
                return "Permiso asignado correctamente";
            switch (codigo)
            {
                case -1: return "Controlador no existe o está inactivo";
                case -2: return "El rol ya tiene asignado este controlador";
                default: return "Error desconocido al asignar permiso";
            }
        }
    }
}
