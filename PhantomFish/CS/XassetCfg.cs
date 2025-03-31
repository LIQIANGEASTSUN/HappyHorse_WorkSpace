using BettaSDK;

public class XassetCfg_Sheet : IJsonConfigBase {

    ///<summary>
    /// ID
    ///<summary>
    public int ID
    {
        get;
        private set;
    }

    ///<summary>
    /// BuildName
    ///<summary>
    public string BuildName
    {
        get;
        private set;
    }

    ///<summary>
    /// GroupId
    ///<summary>
    public int GroupId
    {
        get;
        private set;
    }

    ///<summary>
    /// 是否启用
    /// 不启用 = 0
    /// 启用 = 1
    ///<summary>
    public int Enable
    {
        get;
        private set;
    }

    ///<summary>
    /// 传输方式
    ///  InstallTime = 0
    ///  FastFollow = 1
    ///  OnDemand = 2
    ///<summary>
    public int DeliveryMode
    {
        get;
        private set;
    }

    ///<summary>
    /// 目录
    ///<summary>
    public string Directory
    {
        get;
        private set;
    }

    ///<summary>
    /// 打包模式
    /// PackTogether = 0
    /// PackByFile = 1
    /// PackByFileWithoutExtension = 2
    /// PackByFolder =3
    /// PackByFolderTopOnly = 4
    /// PackByRaw = 5
    /// PackByCustom =6
    ///<summary>
    public int BundleMode
    {
        get;
        private set;
    }

    ///<summary>
    /// 寻址模式
    /// LoadByPath = 0
    /// LoadByName = 1
    /// LoadByNameWithoutExtension = 2
    /// LoadByDependencies = 3
    ///<summary>
    public int AddressMode
    {
        get;
        private set;
    }

    ///<summary>
    /// 测试
    ///<summary>
    public int[] Test
    {
        get;
        private set;
    }

    ///<summary>
    /// 
    ///<summary>
    public float[] Test_1
    {
        get;
        private set;
    }

    ///<summary>
    /// 测试2
    ///<summary>
    public float[][] Test2
    {
        get;
        private set;
    }

    ///<summary>
    /// 测试3
    ///<summary>
    public string[] Test3
    {
        get;
        private set;
    }

    ///<summary>
    /// 测试4
    ///<summary>
    public string Test4
    {
        get;
        private set;
    }

    ///<summary>
    /// 测试5
    ///<summary>
    public json Test5
    {
        get;
        private set;
    }

}