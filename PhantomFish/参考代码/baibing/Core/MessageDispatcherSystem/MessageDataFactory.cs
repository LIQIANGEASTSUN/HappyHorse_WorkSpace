using ProtoBuf;
using System;
using System.Collections.Generic;
using System.IO;
using ProtoBuf.Meta;
using UnityEngine;
using DeserializeData = System.Func<System.IO.MemoryStream, int, ProtoBuf.IExtensible>;


namespace Cookgame.Message
{
    public class MessageDataFactory
    {
        private static readonly RuntimeTypeModel Model = TypeModel.Create();

        private static readonly Dictionary<int, DeserializeData> DeserializeMap = new Dictionary<int, DeserializeData>();

        private static readonly Dictionary<int, Func<IExtensible>> CreatingMap = new Dictionary<int, Func<IExtensible>>();

        //[Obsolete("removed", true)]
        //public static void RegisterDeserializeDataType<T>(int commandType, int commandId) where T : IExtensible
        //{
        //    if (commandType < 0 || commandId < 0)
        //        return;

        //    commandId = (commandType << 8) + commandId;
        //    RegisterDeserializeDataType<T>(commandId);
        //}

        public static void RegisterDeserializeDataType<T>(int msgKey) where T : IExtensible
        {
            if (DeserializeMap.ContainsKey(msgKey))
            {
                DeserializeMap.Remove(msgKey);
            }

            DeserializeMap.Add(msgKey, (ms, dataSize) => DeserializeData<T>(ms, dataSize));
        }

        private static IExtensible DeserializeData<T>(MemoryStream ms, int dataSize) where T : IExtensible
        {
            try
            {
                //return ProtoBuf.Serializer.Deserialize<T>(ms);
                Type type = typeof(T);
                return (IExtensible)Model.Deserialize(ms, null, type, dataSize);
            }
            catch
            {
                GameLog.Log("network", $"反序列消息失败 :{typeof(T)}  {dataSize}", Color.red);
                return (IExtensible) default(T);
            }
        }

        public static IExtensible DeserializeMessageData(int msgKey, MemoryStream ms, int dataSize)
        {
            if (!DeserializeMap.ContainsKey(msgKey))
            {
                if (dataSize > 0)
                {
                    ms.Seek(dataSize, SeekOrigin.Current);
                    GameLog.Log("network", $"(ignore) 消息没有注册, msgKey={(ClientMessage.ClientMsgID) msgKey}({msgKey})  datasize={dataSize}", Color.red);
                }
                return null;
            }
            Func<MemoryStream, int, IExtensible> func = DeserializeMap[msgKey];
            if (func != null)
                return func(ms, dataSize);

            if (dataSize > 0)
            {
                ms.Seek(dataSize, SeekOrigin.Current);
                GameLog.Log("network", $"(ignore) 消息没有注册相映的数据结构, msgKey={(ClientMessage.ClientMsgID) msgKey}({msgKey})  datasize={dataSize}");
            }
            return null;
        }

        //[Obsolete("removed", true)]
        //public static IExtensible DeserializeMessageData(int commandType, int commandId, MemoryStream ms, int dataSize)
        //{
        //    int commandKey = (commandType << 8) + commandId;
        //    return DeserializeMessageData(commandKey, ms, dataSize);
        //}

        //[Obsolete("removed", true)]
        //public static void RegisterCreatingDataType<T>(int commandType, int commandId) where T : IExtensible
        //{
        //    if (commandType < 0 || commandId < 0)
        //        return;

        //    commandId = (commandType << 8) + commandId;
        //    RegisterCreatingDataType<T>(commandId);
        //}

        public static void RegisterCreatingDataType<T>(int msgKey) where T : IExtensible
        {
            if (CreatingMap.ContainsKey(msgKey))
            {
                CreatingMap.Remove(msgKey);
            }
            CreatingMap.Add(msgKey, CreatingData<T>);
        }

        private static IExtensible CreatingData<T>() where T : IExtensible
        {
            T result;
            try
            {
                result = Activator.CreateInstance<T>();
            }
            catch
            {
                result = default;
            }
            return result;
        }

        //[Obsolete("removed", true)]
        //public static IExtensible CreateMessageData(int commandType, int commandId)
        //{
        //    commandId = (commandType << 8) + commandId;
        //    return CreateMessageData(commandId);
        //}

        public static IExtensible CreateMessageData(int msgKey)
        {
            if (!CreatingMap.ContainsKey(msgKey))
                return null;

            Func<IExtensible> func = CreatingMap[msgKey];
            return func?.Invoke();
        }

        //[Obsolete("removed", true)]
        //public static IGameMessage CreateSCMessage(int commandType, int commandId)
        //{
        //    BaseMessage message = new BaseMessage();
        //    message.InitMessage(commandType, commandId);
        //    message.SetDummyMessage(false);
        //    return message;
        //}

        public static IGameMessage CreateSCMessage(int msgKey)
        {
            BaseMessage message = new BaseMessage();
            message.InitMessage(msgKey);
            message.SetDummyMessage(false);
            return message;
        }

        //[Obsolete("removed", true)]
        //public static BaseMessage CreateCSMessage(int commandType, int commandId, int sessionId)
        //{
        //    BaseMessage message = new BaseMessage();
        //    message.InitMessage(commandType, commandId);
        //    message.SetDummyMessage(false);
        //    message.SessionId = sessionId;
        //    message.MessageData = CreateMessageData(commandType, commandId);
        //    return message;
        //}

        public static BaseMessage CreateCSMessage(int msgKey)//, int sessionId)
        {
            BaseMessage message = new BaseMessage();
            message.InitMessage(msgKey);
            message.SetDummyMessage(false);
            //message.SessionId = sessionId;
            message.MessageData = CreateMessageData(msgKey);
            return message;
        }

        public static BaseMessage CreateGatewaySCMessage(int msgKey)
        {
            BaseMessage result = null;
            //ProtocalGateWay.SM_GATE cmdId = (ProtocalGateWay.SM_GATE) commandId;
            //switch (cmdId)
            //{
            //    case ProtocalGateWay.SM_GATE.SM_GATE_INIT_CRYPTO:
            //        result = new GatewayInitSCMessage();
            //        break;
            //    case ProtocalGateWay.SM_GATE.SM_GATE_KEEPACTIVE:
            //        result = new GatewayKeepAliveSCMessage();
            //        break;
            //}

            return result;
        }
    }
}