using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using capa_entidad;

namespace capa_datos
{
    public class CD_Controller
    {
        public List<CONTROLLER> ObtenerControllersPorRol(int IdRol)
        {
            List<CONTROLLER> lista = new List<CONTROLLER>();

            try
            {
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    SqlCommand cmd = new SqlCommand("usp_ObtenerControllersPorRol", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdRol", IdRol);

                    conexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CONTROLLER()
                            {
                                id_controlador = Convert.ToInt32(dr["id_controlador"]),
                                controlador = dr["controlador"].ToString(),
                                accion = dr["accion"].ToString(),
                                descripcion = dr["descripcion"].ToString(),
                                tipo = dr["tipo"].ToString(),
                                estado = Convert.ToBoolean(dr["estado"])
                            });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error al obtener controllers por rol: " + ex.Message);
            }

            return lista;
        }
    }
}
