using System;
using System.IO;
using System.Net;
using System.Runtime.InteropServices;

namespace Cookgame.Network
{
    public class MessageUtils
    {
        private static readonly bool DATA_BIG_ENDIAN = false;

        public static int readInt32FromNetwork(BinaryReader br)
        {
            int num = br.ReadInt32();
            return IPAddress.NetworkToHostOrder(num);
        }

        //*****************************
        public static int readInt32FromStream(MemoryStream inStream)
        {
            if (DATA_BIG_ENDIAN)
                return (inStream.ReadByte() << 24) + (inStream.ReadByte() << 16) + (inStream.ReadByte() << 8) +
                       inStream.ReadByte();
            else
                return inStream.ReadByte() + (inStream.ReadByte() << 8) + (inStream.ReadByte() << 16) +
                       (inStream.ReadByte() << 24);
        }

        public static uint readUint32FromStream(MemoryStream inStream)
        {
            if (DATA_BIG_ENDIAN)
                return (uint) (inStream.ReadByte() << 24) + (uint) (inStream.ReadByte() << 16) +
                       (uint) (inStream.ReadByte() << 8) + (uint) inStream.ReadByte();
            else
                return (uint) inStream.ReadByte() + (uint) (inStream.ReadByte() << 8) +
                       (uint) (inStream.ReadByte() << 16) + (uint) (inStream.ReadByte() << 24);
        }

        public static short readShortFromStream(MemoryStream inStream)
        {
            if (DATA_BIG_ENDIAN)
                return (short) ((inStream.ReadByte() << 8) + inStream.ReadByte());
            else
                return (short) (inStream.ReadByte() + (inStream.ReadByte() << 8));
        }

        public static int readInt32FromBuffer(byte[] buffer, int offset)
        {
            if (DATA_BIG_ENDIAN)
                return (buffer[offset] << 24) + (buffer[offset + 1] << 16) + (buffer[offset + 2] << 8) +
                       buffer[offset + 3];
            else
                return (buffer[offset + 3] << 24) + (buffer[offset + 2] << 16) + (buffer[offset + 1] << 8) +
                       buffer[offset];
        }

        public static uint readUint32FromBuffer(byte[] buffer, int offset)
        {
            if (DATA_BIG_ENDIAN)
                return (uint) (buffer[offset] << 24) + (uint) (buffer[offset + 1] << 16) +
                       (uint) (buffer[offset + 2] << 8) + (uint) buffer[offset + 3];
            else
                return (uint) (buffer[offset + 3] << 24) + (uint) (buffer[offset + 2] << 16) +
                       (uint) (buffer[offset + 1] << 8) + (uint) buffer[offset];
        }


        public static short readShortFromBuffer(byte[] buffer, int offset)
        {
            if (DATA_BIG_ENDIAN)
                return (short) ((buffer[offset] << 8) + buffer[offset + 1]);
            else
                return (short) ((buffer[offset + 1] << 8) + buffer[offset]);
        }

        public static int writeIntToBuffer(byte[] buf, int value, int offset)
        {
            if (DATA_BIG_ENDIAN)
            {
                buf[offset++] = (byte) ((value >> 24) & 255);
                buf[offset++] = (byte) ((value >> 16) & 255);
                buf[offset++] = (byte) ((value >> 8) & 255);
                buf[offset++] = (byte) (value & 255);
            }
            else
            {
                buf[offset++] = (byte) (value & 255);
                buf[offset++] = (byte) ((value >> 8) & 255);
                buf[offset++] = (byte) ((value >> 16) & 255);
                buf[offset++] = (byte) ((value >> 24) & 255);
            }

            return offset;
        }

        public static int writeUintToBuffer(byte[] buf, uint value, int offset)
        {
            if (DATA_BIG_ENDIAN)
            {
                buf[offset++] = (byte) ((value >> 24) & 255);
                buf[offset++] = (byte) ((value >> 16) & 255);
                buf[offset++] = (byte) ((value >> 8) & 255);
                buf[offset++] = (byte) (value & 255);
            }
            else
            {
                buf[offset++] = (byte) (value & 255);
                buf[offset++] = (byte) ((value >> 8) & 255);
                buf[offset++] = (byte) ((value >> 16) & 255);
                buf[offset++] = (byte) ((value >> 24) & 255);
            }

            return offset;
        }


        public static int writeShortToBuffer(byte[] buf, short value, int offset)
        {
            if (DATA_BIG_ENDIAN)
            {
                buf[offset++] = (byte) ((value >> 8) & 255);
                buf[offset++] = (byte) (value & 255);
            }
            else
            {
                buf[offset++] = (byte) (value & 255);
                buf[offset++] = (byte) ((value >> 8) & 255);
            }

            return offset;
        }

        public static void writeIntToStream(MemoryStream outStream, int value)
        {
            if (DATA_BIG_ENDIAN)
            {
                outStream.WriteByte((byte) ((value >> 24) & 255));
                outStream.WriteByte((byte) ((value >> 16) & 255));
                outStream.WriteByte((byte) ((value >> 8) & 255));
                outStream.WriteByte((byte) (value & 255));
            }
            else
            {
                outStream.WriteByte((byte) (value & 255));
                outStream.WriteByte((byte) ((value >> 8) & 255));
                outStream.WriteByte((byte) ((value >> 16) & 255));
                outStream.WriteByte((byte) ((value >> 24) & 255));
            }
        }

        public static void writeUintToStream(MemoryStream outStream, uint value)
        {
            if (DATA_BIG_ENDIAN)
            {
                outStream.WriteByte((byte) ((value >> 24) & 255));
                outStream.WriteByte((byte) ((value >> 16) & 255));
                outStream.WriteByte((byte) ((value >> 8) & 255));
                outStream.WriteByte((byte) (value & 255));
            }
            else
            {
                outStream.WriteByte((byte) (value & 255));
                outStream.WriteByte((byte) ((value >> 8) & 255));
                outStream.WriteByte((byte) ((value >> 16) & 255));
                outStream.WriteByte((byte) ((value >> 24) & 255));
            }
        }

        public static void writeShortToStream(MemoryStream outStream, short value)
        {
            if (DATA_BIG_ENDIAN)
            {
                outStream.WriteByte((byte) ((value >> 8) & 255));
                outStream.WriteByte((byte) (value & 255));
            }
            else
            {
                outStream.WriteByte((byte) (value & 255));
                outStream.WriteByte((byte) ((value >> 8) & 255));
            }
        }

        public static int writeByteToBuffer(byte[] buf, byte value, int offset)
        {
            buf[offset++] = value;
            return offset;
        }

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

        public static byte[] StructToBytes(object structObj, int size)
        {
            byte[] destination = new byte[size];
            IntPtr ptr = Marshal.AllocHGlobal(size);
            Marshal.StructureToPtr(structObj, ptr, false);
            Marshal.Copy(ptr, destination, 0, size);
            Marshal.FreeHGlobal(ptr);
            return destination;
        }


        public static long readUint64FromBuffer(byte[] buffer, int offset)
        {
            if (DATA_BIG_ENDIAN)
                return (long)(buffer[offset] << 56) + (long)(buffer[offset + 1] << 48) + (long)(buffer[offset + 2] << 40) + (long)(buffer[offset + 3] << 32) +
                       (long)(buffer[offset + 4] << 24) + (long)(buffer[offset + 5] << 16) + (long)(buffer[offset + 6] << 8) + (long)(buffer[offset + 7]);
            else
                return (long)(buffer[offset + 7] << 56) + (long)(buffer[offset + 6] << 48) + (long)(buffer[offset + 5] << 40) + (long)(buffer[offset + 4] << 32) +
                       (long)(buffer[offset + 3] << 24) + (long)(buffer[offset + 2] << 16) + (long)(buffer[offset + 1] << 8) + (long)(buffer[offset]);
        }

        public static int writeInt64ToBuffer(byte[] buf, long value, int offset)
        {
            if (DATA_BIG_ENDIAN)
            {
                buf[offset++] = (byte)((value >> 56) & 255);
                buf[offset++] = (byte)((value >> 48) & 255);
                buf[offset++] = (byte)((value >> 40) & 255);
                buf[offset++] = (byte)((value >> 32) & 255);
                buf[offset++] = (byte)((value >> 24) & 255);
                buf[offset++] = (byte)((value >> 16) & 255);
                buf[offset++] = (byte)((value >> 8) & 255);
                buf[offset++] = (byte)(value & 255);
            }
            else
            {
                buf[offset++] = (byte)(value & 255);
                buf[offset++] = (byte)((value >> 8) & 255);
                buf[offset++] = (byte)((value >> 16) & 255);
                buf[offset++] = (byte)((value >> 24) & 255);
                buf[offset++] = (byte)((value >> 32) & 255);
                buf[offset++] = (byte)((value >> 40) & 255);
                buf[offset++] = (byte)((value >> 48) & 255);
                buf[offset++] = (byte)((value >> 56) & 255);
            }

            return offset;
        }

    }
}