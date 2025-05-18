using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Cookgame
{
    public class ConfigDataSystem : ISystem
    {
        private Dictionary<Type, Dictionary<int, MetaDataBase>> _protoMap = new Dictionary<Type, Dictionary<int, MetaDataBase>>();
        private Dictionary<int, MetaDataBase> UpdateTips = new Dictionary<int, MetaDataBase>();
        public void InitSystem()
        {
            //LoadUpdateTipsInfo();
        }

        public void InitData()
        {
            UpdateTips.Clear();
        }

        public T GetMetaData<T>(int id) where T : MetaDataBase
        {
            Type t = typeof(T);
            if (_protoMap.ContainsKey(t))
            {
                Dictionary<int, MetaDataBase> detailMap = _protoMap[t];
                if (detailMap.ContainsKey(id))
                {
                    return (T)(detailMap[id].ProtoClone());
                }
            }
            return null;
        }

        public Dictionary<int, MetaDataBase> GetMetaDataMap<T>() where T : MetaDataBase
        {
            Type t = typeof(T);
            if (_protoMap.ContainsKey(t))
            {
                return _protoMap[t];
            }
            return null;
        }

        private void InitMetaDataFromBytes(Type type, byte[] buffer)
        {
            int offset = 0;
            int totalCount = ByteUtil.BytesToInt(buffer, ref offset);
            int protoCount = ByteUtil.BytesToInt(buffer, ref offset);

            Dictionary<int, MetaDataBase> detailMap = null;
            if (!_protoMap.ContainsKey(type))
            {
                detailMap = new Dictionary<int, MetaDataBase>();
                _protoMap.Add(type, detailMap);
            }
            detailMap = _protoMap[type];

            for (int i = 0; i < protoCount; ++i)
            {
                /// 读取实例数据长度
                int instanceLen = ByteUtil.BytesToInt(buffer, ref offset);
                byte[] instanceBuffer = new byte[instanceLen];
                Array.Copy(buffer, offset, instanceBuffer, 0, instanceLen);
                offset += instanceLen;

                MetaDataBase pb = (MetaDataBase)Activator.CreateInstance(type);
                pb.SerializeFromBytes(instanceBuffer);

                try
                {
                    detailMap.Add(pb.GetProtoID(), pb);
                }
                catch (Exception)
                {
                    GameLog.Log("configData   repeat id = " + pb.GetProtoID() + "  type=" + type);
                }
            }
            if (offset != totalCount)
            {
                //LogSubsystem.Log("serialize proto from byte error typeName " + type.FullName);
            }
        }
        
        private static void _internalLoad(System.IO.BinaryReader inReader, string encryptKey, out string configName, out byte[] encryptData)
        {
            int dataSize = inReader.ReadInt16(); ;
            byte[] configBinaryData = inReader.ReadBytes(dataSize);

            configName = Encoding.UTF8.GetString(configBinaryData);
            //导出原始数据
            dataSize = inReader.ReadInt32();
            encryptData = inReader.ReadBytes(dataSize);
        }

        public void DoUpdate()
        {
            
        }

        public void DoFixedUpdate()
        {
            
        }

        public void DoLateUpdate()
        {
            
        }

        public void OnDispose()
        {
            
        }
    }
}
