using System.Security.Cryptography;
using System.Text;
using System;

public static class Encriptar
{
    public static string GetSHA256(string str)
    {
        if (string.IsNullOrEmpty(str)) return string.Empty;

        using (SHA256 sha256Hash = SHA256.Create())
        {
            byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(str));

            StringBuilder builder = new StringBuilder();
            for (int i = 0; i < bytes.Length; i++)
            {
                builder.Append(bytes[i].ToString("x2"));
            }
            return builder.ToString();
        }
    }
}