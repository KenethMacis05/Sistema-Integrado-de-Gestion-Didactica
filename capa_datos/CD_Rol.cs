using System;
using System.Collections.Generic;
using System.Linq;
using capa_entidad;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;

namespace capa_datos
{
    public class CD_Rol
    {
        public List<ROL> Listar()
        {
            List<ROL> lst = new List<ROL>();

            try
            {
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    string query = "SELECT * FROM ROL";
                    SqlCommand cmd = new SqlCommand(query, conexion);
                    cmd.CommandType = CommandType.Text;

                    conexion.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lst.Add(
                                new ROL
                                {
                                    id_rol = Convert.ToInt32(dr["id_rol"]),
                                    descripcion = dr["descripcion"].ToString(),                                    
                                    estado = Convert.ToBoolean(dr["estado"]),
                                    fecha_registro = Convert.ToDateTime(dr["fecha_registro"])
                                }
                                );
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error al listar los usuarios: " + ex.Message);
            }
            return lst;
        }

        //Crear nuvo rol
        public int Crear(ROL rol, out string mensaje)
        {
            int idautogenerado = 0;
            mensaje = string.Empty;

            try
            {
                // Crear conexión
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    // Consulta SQL con parámetros
                    SqlCommand cmd = new SqlCommand("usp_CrearRol", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Agregar parámetros
                    cmd.Parameters.AddWithValue("Descripcion", rol.descripcion);                   
                    
                    // Parámetros de salida
                    cmd.Parameters.Add("Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                    // Abrir conexión
                    conexion.Open();

                    // Ejecutar comando
                    cmd.ExecuteNonQuery();

                    // Obtener valores de los parámetros de salida
                    idautogenerado = Convert.ToInt32(cmd.Parameters["Resultado"].Value);
                    mensaje = cmd.Parameters["Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                idautogenerado = 0;
                mensaje = "Error al registrar el rol: " + ex.Message;
            }

            return idautogenerado;
        }

        //Actualizar rol
        public bool Editar(ROL rol, out string mensaje)
        {
            bool resultado = false;
            mensaje = string.Empty;
            try
            {
                // Crear conexión
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    // Consulta SQL con parámetros
                    SqlCommand cmd = new SqlCommand("usp_ActualizarRol", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Agregar parámetros
                    cmd.Parameters.AddWithValue("IdRol", rol.id_rol);
                    cmd.Parameters.AddWithValue("Descripcion", rol.descripcion ?? (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("Estado", rol.estado);

                    // Parámetros de salida
                    cmd.Parameters.Add("Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                    // Abrir conexión
                    conexion.Open();

                    // Ejecutar comando
                    cmd.ExecuteNonQuery();

                    // Obtener valores de los parámetros de salida
                    resultado = cmd.Parameters["Resultado"].Value != DBNull.Value && Convert.ToBoolean(cmd.Parameters["Resultado"].Value);
                    mensaje = cmd.Parameters["Mensaje"].Value != DBNull.Value ? cmd.Parameters["Mensaje"].Value.ToString() : "Mensaje no disponible.";
                }
            }
            catch (Exception ex)
            {
                resultado = false;
                mensaje = "Error al actualizar el rol: " + ex.Message;
            }
            return resultado;
        }

        // Eliminar rol
        public bool Eliminar(int id_rol, out string mensaje)
        {
            bool resultado = false;
            mensaje = string.Empty;
            try
            {
                // Crear conexión
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    // Consulta SQL con parámetros
                    SqlCommand cmd = new SqlCommand("usp_EliminarRol", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Agregar parámetro de entrada
                    cmd.Parameters.AddWithValue("IdRol", id_rol);

                    // Agregar parámetro de salida
                    cmd.Parameters.Add("Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;

                    // Abrir conexión
                    conexion.Open();
                    cmd.ExecuteNonQuery();

                    // Obtener valores de los parámetros de salida
                    resultado = cmd.Parameters["Resultado"].Value != DBNull.Value && Convert.ToBoolean(cmd.Parameters["Resultado"].Value);
                    mensaje = resultado ? "Rol eliminado correctamente" : "El rol no existe";
                }
            }
            catch (Exception ex)
            {
                resultado = false;
                mensaje = "Error al eliminar el rol: " + ex.Message;
            }
            return resultado;
        }
    }
}
