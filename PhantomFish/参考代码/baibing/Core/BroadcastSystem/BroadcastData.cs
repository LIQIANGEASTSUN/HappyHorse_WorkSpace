using System;
using UnityEngine;

namespace Cookgame.Broadcast
{
    public delegate void BroadcastDataListener(IBroadcastData data, int flag);
    public interface IBroadcastData
    {

    }

    public static class BroadcastDataHelper
    {
        //public static bool GetIntData(this IBroadcastData shareable, out int data)
        //{
        //    data = 0;
        //    BroadcastDataInt dataType = shareable as BroadcastDataInt;
        //    if (dataType == null) return false;
        //    data = dataType.IntData;
        //    return true;
        //}

        //public static int GetIntData(this IBroadcastData shareable)
        //{
        //    try
        //    {
        //        return (shareable as BroadcastDataInt).IntData;
        //    }
        //    catch (Exception e)
        //    {
        //        LogException("GetIntData", shareable, e);
        //        return 0;
        //    }
        //}

        //public static bool GetFloatData(this IBroadcastData shareable, out float data)
        //{
        //    data = 0;
        //    BroadcastDataFloat dataType = shareable as BroadcastDataFloat;
        //    if (dataType == null) return false;
        //    data = dataType.FloatData;
        //    return true;
        //}

        //public static float GetFloatData(this IBroadcastData shareable)
        //{
        //    try
        //    {
        //        return (shareable as BroadcastDataFloat).FloatData;
        //    }
        //    catch (Exception e)
        //    {
        //        LogException("GetFloatData", shareable, e);
        //        return 0;
        //    }
        //}

        //public static bool GetUintData(this IBroadcastData shareable, out uint data)
        //{
        //    data = 0;
        //    BroadcastDataUint dataType = shareable as BroadcastDataUint;
        //    if (dataType == null) return false;
        //    data = dataType.UintData;
        //    return true;
        //}

        //public static uint GetUintData(this IBroadcastData shareable)
        //{
        //    try
        //    {
        //        return (shareable as BroadcastDataUint).UintData;
        //    }
        //    catch (Exception e)
        //    {
        //        LogException("GetUintData", shareable, e);
        //        return 0;
        //    }
        //}

        //public static bool GetBoolData(this IBroadcastData shareable, out bool data)
        //{
        //    data = false;
        //    BroadcastDataBool dataType = shareable as BroadcastDataBool;
        //    if (dataType == null) return false;
        //    data = dataType.BoolData;
        //    return true;
        //}

        //public static bool GetBoolData(this IBroadcastData shareable)
        //{
        //    try
        //    {
        //        return (shareable as BroadcastDataBool).BoolData;
        //    }
        //    catch (Exception e)
        //    {
        //        LogException("GetBoolData", shareable, e);
        //        return false;
        //    }
        //}

        //public static bool GetStringData(this IBroadcastData shareable, out string data)
        //{
        //    data = string.Empty;
        //    BroadcastDataString dataType = shareable as BroadcastDataString;
        //    if (dataType == null) return false;
        //    data = dataType.StrData;
        //    return true;
        //}

        //public static string GetStringData(this IBroadcastData shareable)
        //{
        //    try
        //    {
        //        return (shareable as BroadcastDataString).StrData;
        //    }
        //    catch (Exception e)
        //    {
        //        LogException("GetStringData", shareable, e);
        //        return null;
        //    }
        //}

        //public static T GetObjectData<T>(this IBroadcastData shareable)
        //{
        //    var o = shareable as BroadcastDataObject;
        //    if (o != null)
        //    {
        //        try
        //        {
        //            return (T) o.ObjData;
        //        }
        //        catch (Exception)
        //        {
        //            return default(T);
        //        }
        //    }

        //    return default(T);
        //}
        public static T GetData<T>(this IBroadcastData shareable)
        {
            if (shareable is BroadcastData<T> o)
            {
                try
                {
                    return o.DataValue;
                }
                catch (Exception)
                {
                    return default(T);
                }
            }

            return default(T);
        }

        //private static void LogException(string msg, IBroadcastData data, Exception e)
        //{
        //    msg += " Exception ";
        //    if (data == null)
        //    {
        //        msg += "IBroadcastData:null";
        //    }
        //    else
        //    {
        //        msg += string.Format("IBroadcastDataType:{0}  Data:{1}", data.GetType(), JsonUtility.ToJson(data));
        //    }

        //    GameLog.Log(msg, e);
        //}
    }

    //public class BroadcastDataInt : IBroadcastData
    //{
    //    public int IntData;

    //    public BroadcastDataInt()
    //    {
    //    }

    //    public BroadcastDataInt(int data)
    //    {
    //        IntData = data;
    //    }
    //}

    //public class BroadcastDataFloat : IBroadcastData
    //{
    //    public float FloatData;

    //    public BroadcastDataFloat()
    //    {
    //    }

    //    public BroadcastDataFloat(float data)
    //    {
    //        FloatData = data;
    //    }
    //}

    //public class BroadcastDataBool : IBroadcastData
    //{
    //    public bool BoolData;

    //    public BroadcastDataBool()
    //    {
    //    }

    //    public BroadcastDataBool(bool data)
    //    {
    //        BoolData = data;
    //    }
    //}

    //public class BroadcastDataUint : IBroadcastData
    //{
    //    public uint UintData;

    //    public BroadcastDataUint()
    //    {
    //    }

    //    public BroadcastDataUint(uint data)
    //    {
    //        UintData = data;
    //    }
    //}

    //public class BroadcastDataString : IBroadcastData
    //{
    //    public string StrData;

    //    public BroadcastDataString()
    //    {
    //    }

    //    public BroadcastDataString(string data)
    //    {
    //        StrData = data;
    //    }
    //}

    //public class BroadcastDataObject : IBroadcastData
    //{
    //    public object ObjData;

    //    public BroadcastDataObject()
    //    {

    //    }

    //    public BroadcastDataObject(object data)
    //    {
    //        ObjData = data;
    //    }
    //}


    public class BroadcastData<T> : IBroadcastData
    {
        public T DataValue;

        public BroadcastData()
        {
        }

        public BroadcastData(T data)
        {
            DataValue = data;
        }
    }
}