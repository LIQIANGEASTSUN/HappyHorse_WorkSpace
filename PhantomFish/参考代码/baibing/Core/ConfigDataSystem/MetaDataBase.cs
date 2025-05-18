using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.InteropServices;

public struct PropertyDef
{
    public string proName;
    public string proType;
    public string proDesc;
}

public class MetaDataBase
{
    public virtual MetaDataBase ProtoClone() { return (MetaDataBase)this.MemberwiseClone(); }
    public virtual int GetProtoID() { return -1; }
    public virtual void SerializeFromString(string[] s){ }
    public virtual void SerializeFromString(string s){ }
    public virtual void SerializeFromBytes(byte[] data) { }
    public virtual void SetProperty(int i, string v) { }
    public virtual void SetProperty(ref int i, byte[] buffer, ref int offset) { }

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

    public virtual byte[] SerializeToBytes(List<PropertyDef> defs) 
    {
        byte[] buffer = new byte[4096];
        int totalCount = 0;
        Type t = GetType();
        for (int i = 0; i < defs.Count; ++i)
        {
            if (totalCount > 4096)
            {
				throw (new Exception("字段超过4096个"));
            }
            PropertyDef pd = defs[i];
            if (pd.proName != "")
            {
                FieldInfo fi = t.GetField(pd.proName, BindingFlags.Public | BindingFlags.DeclaredOnly | BindingFlags.Instance);
                if (fi == null)
                {
					throw (new Exception("字段 " + pd.proName + " 不存在"));
                }
                object v = fi.GetValue(this);
                switch (pd.proType)
                {
                    case "int":
                        int iv = (Int32)v;
                        Array.Copy(IntToBytes(iv), 0, buffer, totalCount, sizeof(int));
                        totalCount += sizeof(int);
                        break;
                    case "float":
                        float fv = (Single)v;
                        Array.Copy(FloatToBytes(fv), 0, buffer, totalCount, sizeof(float));
                        totalCount += sizeof(float);
                        break;
                    case "string":
                        string sv = (string)v;
                        if (sv != null)
                        {
                            char[] cBuffer = sv.ToCharArray();
                            byte[] bBuffer = Encoding.UTF8.GetBytes(cBuffer);
                            Array.Copy(IntToBytes(bBuffer.Length), 0, buffer, totalCount, sizeof(int));
                            totalCount += sizeof(int);
                            Array.Copy(bBuffer, 0, buffer, totalCount, bBuffer.Length);
                            totalCount += bBuffer.Length;
                        }
                        else
                        {
                            int len = 0;
                            Array.Copy(IntToBytes(len), 0, buffer, totalCount, sizeof(int));
                            totalCount += sizeof(int);
                        }
                        break;
                    case "bool":
                        Boolean bv = (Boolean)v;
                        int biv = bv ? 1 : 0;
                        Array.Copy(IntToBytes(biv), 0, buffer, totalCount, sizeof(int));
                        totalCount += sizeof(int);
                        break;
                    default:
                        throw (new Exception());

                }       
            }
        }        
        byte[] ret = new byte[totalCount];
        Array.Copy(buffer, 0, ret, 0, totalCount);
        return ret;
    }
}
