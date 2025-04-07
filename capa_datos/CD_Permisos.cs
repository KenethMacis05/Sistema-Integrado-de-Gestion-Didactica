using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using capa_entidad;
using System.Data.SqlClient;
using System.Data;
using System.Runtime.Remoting.Messaging;
using System.Web.Mvc;

namespace capa_datos
{
    public class CD_Permisos
    {
        public bool VerificarPermiso(int IdUsuario, string controlador, string accion)
        {
            bool tienePermiso = false;

            try
            {
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    SqlCommand cmd = new SqlCommand("usp_VerificarPermiso", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("IdUsuario", IdUsuario);
                    cmd.Parameters.AddWithValue("Controlador", controlador);
                    cmd.Parameters.AddWithValue("Accion", accion);

                    conexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            tienePermiso = Convert.ToBoolean(dr["tiene_permiso"]);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error al verificar permiso: " + ex.Message);
            }

            return tienePermiso;
        }
    }
}
