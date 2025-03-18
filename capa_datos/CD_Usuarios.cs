using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using capa_entidad;
using System.Data.SqlClient;
using System.Data;
using System.Runtime.Remoting.Messaging;

namespace capa_datos
{
    public class CD_Usuarios
    {
        //Listar usuarios
        public List<USUARIOS> Listar()
        {
            List<USUARIOS> lst = new List<USUARIOS>();

            try
            {
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    string query = "SELECT * FROM USUARIOS";
                    SqlCommand cmd = new SqlCommand(query, conexion);
                    cmd.CommandType = CommandType.Text;

                    conexion.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lst.Add(
                                new USUARIOS
                                {
                                    id_usuario = Convert.ToInt32(dr["id_usuario"]),
                                    pri_nombre = dr["pri_nombre"].ToString(),
                                    seg_nombre = dr["seg_nombre"].ToString(),
                                    pri_apellido = dr["pri_apellido"].ToString(),
                                    seg_apellido = dr["seg_apellido"].ToString(),
                                    usuario = dr["usuario"].ToString(),
                                    contrasena = dr["contrasena"].ToString(),
                                    correo = dr["correo"].ToString(),
                                    fk_rol = Convert.ToInt32(dr["fk_rol"]),
                                    estado = Convert.ToBoolean(dr["estado"])
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

        //Login usuario
        public USUARIOS LoginUsuario(string usuario, string contrasena)
        {
            USUARIOS usuarioAutenticado = null; // Usar un solo objeto en lugar de una lista

            using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
            {
                try
                {
                    // Consulta SQL con parámetros
                    string query = "SELECT * FROM USUARIOS WHERE usuario = @usuario AND contrasena = @contrasena AND estado = 1;";
                    SqlCommand cmd = new SqlCommand(query, conexion);

                    // Agregar parámetros
                    cmd.Parameters.AddWithValue("@usuario", usuario);
                    cmd.Parameters.AddWithValue("@contrasena", contrasena);
                    cmd.CommandType = CommandType.Text;

                    conexion.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read()) // Si encuentra un registro
                        {
                            usuarioAutenticado = new USUARIOS
                            {
                                id_usuario = Convert.ToInt32(dr["id_usuario"]),
                                pri_nombre = dr["pri_nombre"].ToString(),
                                seg_nombre = dr["seg_nombre"].ToString(),
                                pri_apellido = dr["pri_apellido"].ToString(),
                                seg_apellido = dr["seg_apellido"].ToString(),
                                usuario = dr["usuario"].ToString(),
                                contrasena = dr["contrasena"].ToString(),                                
                                correo = dr["correo"].ToString(),
                                fk_rol = Convert.ToInt32(dr["fk_rol"]),
                                estado = Convert.ToBoolean(dr["estado"])
                            };
                        }
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception("Error al autenticar el usuario: " + ex.Message);
                }
            }

            return usuarioAutenticado; // Retorna el usuario autenticado o null si no se encontró
        }

        // Registrar usuario
        public int RegistrarUsuario(USUARIOS usuario, out string mensaje)
        {
            int idautogenerado = 0;
            mensaje = string.Empty;            

            try
            {
                // Crear conexión
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    // Consulta SQL con parámetros
                    SqlCommand cmd = new SqlCommand("usp_RegistrarUsuario", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Agregar parámetros
                    cmd.Parameters.AddWithValue("pri_nombre", usuario.pri_nombre);
                    cmd.Parameters.AddWithValue("seg_nombre", usuario.seg_nombre);
                    cmd.Parameters.AddWithValue("pri_apellido", usuario.pri_apellido);
                    cmd.Parameters.AddWithValue("seg_apellido", usuario.seg_apellido);
                    cmd.Parameters.AddWithValue("usuario", usuario.usuario);
                    cmd.Parameters.AddWithValue("contrasena", usuario.contrasena);
                    cmd.Parameters.AddWithValue("correo", usuario.correo);
                    cmd.Parameters.AddWithValue("fk_rol", usuario.fk_rol);
                    cmd.Parameters.AddWithValue("estado", usuario.estado);

                    // Parámetros de salida
                    cmd.Parameters.Add("Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                    // Abrir conexión
                    conexion.Open();

                    // Ejecutar comando
                    cmd.ExecuteNonQuery();

                    // Obtener valores de los parámetros de salida
                    idautogenerado = Convert.ToInt32(cmd.Parameters["Resultado"].Value);                    
                    mensaje = cmd.Parameters["@mensaje"].Value.ToString();                    
                }
            }
            catch (Exception ex)
            {
                idautogenerado = 0;
                mensaje = "Error al registrar el usuario: " + ex.Message;
            }

            return idautogenerado;
        }

        // Actualizar usuario
        public bool ActualizarUsuario(USUARIOS usuario, out string mensaje)
        {
            bool resultado = false;            
            mensaje = string.Empty;
            try
            {
                // Crear conexión
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    // Consulta SQL con parámetros
                    SqlCommand cmd = new SqlCommand("usp_ModificarUsuario", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    // Agregar parámetros
                    cmd.Parameters.AddWithValue("id_usuario", usuario.id_usuario);
                    cmd.Parameters.AddWithValue("pri_nombre", usuario.pri_nombre);
                    cmd.Parameters.AddWithValue("seg_nombre", usuario.seg_nombre);
                    cmd.Parameters.AddWithValue("pri_apellido", usuario.pri_apellido);
                    cmd.Parameters.AddWithValue("seg_apellido", usuario.seg_apellido);
                    cmd.Parameters.AddWithValue("usuario", usuario.usuario);
                    cmd.Parameters.AddWithValue("contrasena", usuario.contrasena);
                    cmd.Parameters.AddWithValue("correo", usuario.correo);
                    cmd.Parameters.AddWithValue("fk_rol", usuario.fk_rol);
                    cmd.Parameters.AddWithValue("estado", usuario.estado);
                    // Parámetros de salida
                    cmd.Parameters.Add("Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    // Abrir conexión
                    conexion.Open();
                    // Ejecutar comando
                    cmd.ExecuteNonQuery();
                    // Obtener valores de los parámetros de salida
                    resultado = Convert.ToBoolean(cmd.Parameters["Resultado"].Value);
                    mensaje = cmd.Parameters["mensaje"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                resultado = false;
                mensaje = "Error al actualizar el usuario: " + ex.Message;
            }
            return resultado;
        }

        // Eliminar usuario
        public bool EliminarUsuario(int id_usuario, out string mensaje)
        {
            bool resultado = false;
            mensaje = string.Empty;
            try
            {
                // Crear conexión
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    // Consulta SQL con parámetros
                    SqlCommand cmd = new SqlCommand("DELETE TOP (1) FROM USUARIOS WHERE id_usuario = @id_usuario", conexion);
                    cmd.CommandType = CommandType.Text;
                    // Agregar parámetros
                    cmd.Parameters.AddWithValue("id_usuario", id_usuario);                    
                    
                    // Abrir conexión
                    conexion.Open();                    

                    // Obtener valores de los parámetros de salida
                    resultado = cmd.ExecuteNonQuery() > 0 ? true : false;
                }
            }
            catch (Exception ex)
            {
                resultado = false;
                mensaje = "Error al eliminar el usuario: " + ex.Message;
            }
            return resultado;
        }
    }
}
