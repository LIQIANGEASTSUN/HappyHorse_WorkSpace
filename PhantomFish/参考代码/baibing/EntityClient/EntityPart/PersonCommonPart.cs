using ClientMessage;
using ProtoBuf;

namespace Cookgame.Entity
{
    class PersonCommonPart : IEntityPart
    {
        private IPerson __master = null;
        public uint GetPartID()
        {
            return (uint)Enum_PersonPart_Type.EN_PERSON_PART_MISC;
        }
        public IPerson GetMaster()
        {
            return __master;
        }
        public bool Create(IPerson master)
        {
            __master = master;
            return true;
        }

        public bool UpdateProp(byte[] EntityPartData)
        {
            return true;
        }

        public bool UpdateProp(IExtensible msgData)
        {
            return true;
        }
    }
}