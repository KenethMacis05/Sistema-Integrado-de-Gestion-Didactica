using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using capa_entidad;


namespace capa_datos
{
    public class CD_Carpeta
    {
        // Listar carpetas
        public List<CARPETA> Listar(int id_usuario)
        {
            List<CARPETA> listaCarpeta = new List<CARPETA>();

            try
            {
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    string query = "SELECT TOP 10 * FROM CARPETA WHERE fk_id_usuario = @id_usuario ORDER BY fecha_registro DESC";
            
                    SqlCommand cmd = new SqlCommand(query, conexion);
                    cmd.Parameters.AddWithValue("@id_usuario", id_usuario); // Agregar esta línea

                    cmd.CommandType = CommandType.Text;

                    conexion.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            listaCarpeta.Add(
                                new CARPETA
                                {
                                    id_carpeta = Convert.ToInt32(dr["id_carpeta"]),
                                    nombre = dr["nombre"].ToString(),
                                    fecha_registro = Convert.ToDateTime(dr["fecha_registro"]),
                                    estado = Convert.ToBoolean(dr["estado"]),
                                    fk_id_usuario = new USUARIOS() { id_usuario = Convert.ToInt32(dr["fk_id_usuario"]) }
                                }
                            );
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error al listar las carpetas: " + ex.Message);
            }
            return listaCarpeta;
        }

    }
}
