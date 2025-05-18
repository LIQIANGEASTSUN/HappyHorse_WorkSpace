using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;

public static class ByteUtil
{
    public static bool debugVerbose = false;
    public static bool IS_DEBUG_PACKDATA = true;
    public static bool IS_UNICODE_ENCODING = false;
    public static bool IS_UTF8_ENCODING = false;

    public static object BytesToStuct(byte[] bytes, Type type, int size)
    {
        if (size > bytes.Length)
        {
            return null;
        }
        IntPtr destination = Marshal.AllocHGlobal(size);
        Marshal.Copy(bytes, 0, destination, size);
        object obj2 = Marshal.PtrToStructure(destination, type);
        Marshal.FreeHGlobal(destination);
        return obj2;
    }

    public static int BytesToInt(byte[] bytes, ref int offset)
    {
        int size = sizeof(int);
        Int32 i = 0;
        byte[] buffer = new byte[size];
        Array.Copy(bytes, offset, buffer, 0, size);
        i = (Int32)BytesToStuct(buffer, typeof(Int32), size);
        offset += size;
        return i;
    }

    public static float BytesToFloat(byte[] bytes, ref int offset)
    {
        int size = sizeof(float);
        Single f = 0;
        byte[] buffer = new byte[size];
        Array.Copy(bytes, offset, buffer, 0, size);
        f = (Single)BytesToStuct(buffer, typeof(Single), size);
        offset += size;
        return f;
    }

    public static bool Memcpy(ref List<char> buff, int buffIndex, char[] s, int charCount)
    {
        byte[] buffer = ToBytes(buff.ToArray());
        bool flag = Memcpy(ref buffer, buffIndex, s, charCount);
        if (flag)
        {
            buff = new List<char>((IEnumerable<char>)ToChars(buffer));
        }
        return flag;
    }

    public static bool Memcpy(ref byte[] buff, int buffIndex, char[] s, int charCount)
    {
        try
        {
            byte[] buffer = ToBytes(s);
            int index = buffIndex;
            for (int i = 0; i < charCount; i++)
            {
                if ((index < buff.Length) && (i < buffer.Length))
                {
                    buff[index] = buffer[i];
                }
                index++;
            }
        }
        catch
        {
            return false;
        }
        return true;
    }

    public static bool Memmove(List<char> src, ulong srcIndex, ref List<char> dst, ulong dstIndex, ulong charCount)
    {
        char[] sourceArray = src.ToArray();
        char[] destinationArray = dst.ToArray();
        try
        {
            Array.Copy(sourceArray, (int)srcIndex, destinationArray, (int)dstIndex, (int)charCount);
        }
        catch
        {
            return false;
        }
        dst = new List<char>(destinationArray);
        return true;
    }

    public static byte[] StructToBytes(object structObj, int size)
    {
        byte[] destination = new byte[size];
        IntPtr ptr = Marshal.AllocHGlobal(size);
        Marshal.StructureToPtr(structObj, ptr, false);
        Marshal.Copy(ptr, destination, 0, size);
        Marshal.FreeHGlobal(ptr);
        return destination;
    }

    public static byte[] IntToBytes(int i)
    {
        Int32 i32 = new Int32();
        i32 = i;
        return StructToBytes(i32, sizeof(int));
    }

    public static byte[] FloatToBytes(float f)
    {
        Single s = new Single();
        s = f;
        return StructToBytes(s, sizeof(float));
    }

    public static byte[] ToBytes(char[] chr)
    {
        if (null == chr)
            return null;

        List<byte> list = new List<byte>();
        int index = 0;
        index = 0;
        while (index < chr.Length)
        {
            char ch = chr[index];
            byte item = Convert.ToByte(ch);
            list.Add(item);
            index++;
        }
        return list.ToArray();
    }

    public static char[] ToChars(byte[] bpara)
    {
        List<char> list = new List<char>();
        for (int i = 0; i < bpara.Length; i++)
        {
            byte num2 = bpara[i];
            list.Add(Convert.ToChar(num2));
        }
        return list.ToArray();
    }

    public static string ToString(byte[] bytes)
    {
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < bytes.Length; i++)
        {
            byte num2 = bytes[i];
            builder.Append("-");
            builder.Append(num2);
            i++;
        }
        return builder.ToString();
    }
}
