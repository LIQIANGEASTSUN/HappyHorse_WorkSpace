using System;
using System.Collections.Generic;
using ClientMessage;

public interface IUpdateAttrAble
{
    void updateAttr(uint UpDateMode, Dictionary<UInt32, VariantData> prop);
}