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
                                    telefono = Convert.ToInt32(dr["telefono"]),
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

        public USUARIOS ObtenerUsuarioPorId(int idUsuario)
        {
            using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
            {
                string query = "SELECT u.id_usuario, u.pri_nombre, u.seg_nombre, u.pri_apellido, u.seg_apellido, u.usuario, u.correo, u.telefono, u.fk_rol, r.descripcion, u.estado, u.reestablecer FROM USUARIOS u INNER JOIN ROL r ON r.id_rol = u.fk_rol WHERE id_usuario = @idUsuario";

                SqlCommand cmd = new SqlCommand(query, conexion);
                cmd.CommandType = CommandType.Text;
                cmd.Parameters.AddWithValue("@idUsuario", idUsuario);
                 
                conexion.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        return new USUARIOS
                        {
                            id_usuario = Convert.ToInt32(dr["id_usuario"]),
                            pri_nombre = dr["pri_nombre"].ToString(),
                            seg_nombre = dr["seg_nombre"].ToString(),
                            pri_apellido = dr["pri_apellido"].ToString(),
                            seg_apellido = dr["seg_apellido"].ToString(),
                            usuario = dr["usuario"].ToString(),
                            correo = dr["correo"].ToString(),
                            telefono = Convert.ToInt32(dr["telefono"]),
                            fk_rol = Convert.ToInt32(dr["fk_rol"]),
                            descripcion = dr["descripcion"].ToString(),
                            estado = Convert.ToBoolean(dr["estado"]),
                            reestablecer = Convert.ToBoolean(dr["reestablecer"])
                        };
                    }
                }
            }
            return null;
        }

        //Login usuario
        public USUARIOS LoginUsuario(string usuario, string contrasena, out string mensaje)
        {
            USUARIOS usuarioAutenticado = null;
            mensaje = string.Empty;

            using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_LoginUsuario", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("Usuario", usuario);
                    cmd.Parameters.AddWithValue("Clave", contrasena);

                    // Parámetros de salida
                    cmd.Parameters.Add("Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("IdUsuario", SqlDbType.Int).Direction = ParameterDirection.Output;

                    conexion.Open();
                    cmd.ExecuteNonQuery();

                    // Obtener valores de salida
                    mensaje = cmd.Parameters["Mensaje"].Value.ToString();
                    int idUsuario = cmd.Parameters["IdUsuario"].Value == DBNull.Value ? 0 : Convert.ToInt32(cmd.Parameters["IdUsuario"].Value);

                    if (idUsuario > 0)
                    {                     
                        usuarioAutenticado = ObtenerUsuarioPorId(idUsuario);
                        if (usuarioAutenticado != null && !usuarioAutenticado.estado)
                        {
                            mensaje = "Usuario inactivo";
                            return null;
                        }

                        if (usuarioAutenticado.reestablecer)
                        {
                            mensaje = "Debe restablecer su contraseña";
                        }
                    }
                }
                catch (Exception ex)
                {
                    mensaje = "Error en el sistema: " + ex.Message;
                }
            }

            return usuarioAutenticado;
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
                    SqlCommand cmd = new SqlCommand("usp_CrearUsuario", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Agregar parámetros
                    cmd.Parameters.AddWithValue("PriNombre", usuario.pri_nombre);
                    cmd.Parameters.AddWithValue("SegNombre", usuario.seg_nombre);
                    cmd.Parameters.AddWithValue("PriApellido", usuario.pri_apellido);
                    cmd.Parameters.AddWithValue("SegApellido", usuario.seg_apellido);
                    cmd.Parameters.AddWithValue("Usuario", usuario.usuario);
                    cmd.Parameters.AddWithValue("Clave", usuario.contrasena);
                    cmd.Parameters.AddWithValue("Correo", usuario.correo);
                    cmd.Parameters.AddWithValue("Telefono", usuario.telefono);
                    cmd.Parameters.AddWithValue("FkRol", usuario.fk_rol);
                    cmd.Parameters.AddWithValue("Estado", usuario.estado);                    

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
                    SqlCommand cmd = new SqlCommand("usp_ActualizarUsuario", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Agregar parámetros
                    cmd.Parameters.AddWithValue("IdUsuario", usuario.id_usuario);
                    cmd.Parameters.AddWithValue("PriNombre", usuario.pri_nombre ?? (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("SegNombre", usuario.seg_nombre);
                    cmd.Parameters.AddWithValue("PriApellido", usuario.pri_apellido ?? (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("SegApellido", usuario.seg_apellido);
                    cmd.Parameters.AddWithValue("Usuario", usuario.usuario ?? (object)DBNull.Value);                    
                    cmd.Parameters.AddWithValue("Correo", usuario.correo ?? (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("Telefono", usuario.telefono);
                    cmd.Parameters.AddWithValue("FkRol", usuario.fk_rol);
                    cmd.Parameters.AddWithValue("Estado", usuario.estado);
                    
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
                mensaje = "Error al actualizar el usuario: " + ex.Message;
            }
            return resultado;
        }

        // Cambiar contraseña
        public int ReestablecerContrasena(int idUsuario, string claveActual, string claveNueva, out string mensaje)
        {
            int resultado = 0;
            mensaje = string.Empty;
            try
            {
                using (SqlConnection conexion = new SqlConnection(Conexion.conexion))
                {
                    SqlCommand cmd = new SqlCommand("usp_ReestablecerContrasena", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("IdUsuario", idUsuario);
                    cmd.Parameters.AddWithValue("ClaveActual", claveActual);
                    cmd.Parameters.AddWithValue("ClaveNueva", claveNueva);

                    cmd.Parameters.Add("Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("Mensaje", SqlDbType.VarChar, 255).Direction = ParameterDirection.Output;

                    conexion.Open();
                    cmd.ExecuteNonQuery();

                    resultado = Convert.ToInt32(cmd.Parameters["Resultado"].Value);
                    mensaje = cmd.Parameters["Mensaje"].Value.ToString();

                    if (resultado == 1 && string.IsNullOrEmpty(mensaje))
                    {
                        mensaje = "Contraseña actualizada exitosamente";
                    }
                }
            }
            catch (Exception ex)
            {
                resultado = 0;
                mensaje = "Error al cambiar la contraseña: " + ex.Message;
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
                    SqlCommand cmd = new SqlCommand("usp_EliminarUsuario", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Agregar parámetro de entrada
                    cmd.Parameters.AddWithValue("IdUsuario", id_usuario);

                    // Agregar parámetro de salida
                    cmd.Parameters.Add("Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;

                    // Abrir conexión
                    conexion.Open();
                    cmd.ExecuteNonQuery();

                    // Obtener valores de los parámetros de salida
                    resultado = cmd.Parameters["Resultado"].Value != DBNull.Value && Convert.ToBoolean(cmd.Parameters["Resultado"].Value);
                    mensaje = resultado ? "Usuario eliminado correctamente" : "El usuario no existe";
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
