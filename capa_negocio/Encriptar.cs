using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace capa_negocio
{
    class Encriptar
    {
        //Encriptar contraseña con SHA256
        public static string GetSHA256(string str)
        {
            SHA256 sha256 = System.Security.Cryptography.SHA256Managed.Create();
            ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
            byte[] stream = null;
            StringBuilder sb = new System.Text.StringBuilder();
            stream = sha256.ComputeHash(encoding.GetBytes(str));
            for (int i = 0; i < stream.Length; i++) sb.AppendFormat("{0:x2}", stream[i]);
            return sb.ToString();
        }
    }
}
