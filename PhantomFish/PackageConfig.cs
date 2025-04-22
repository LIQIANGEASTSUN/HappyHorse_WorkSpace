
namespace BettaSDK.Editor
{
    /// <summary>
    /// 配置文件相对层级结构
    /// </summary>
    public enum PackageRelativePath
    {
        /// <summary>
        /// Assets 子目录
        /// </summary>
        [EnumAttirbute("Assets 子目录")]
        Assets = 1,

        /// <summary>
        /// Assets 父级目录
        /// </summary>
        [EnumAttirbute("Assets 父级目录")]
        AssetsParent = 2,

        /// <summary>
        /// Assets 祖父级目录
        /// </summary>
        [EnumAttirbute("Assets 祖父级目录")]
        AssetsGrandfather = 3,

        /// <summary>
        /// 自定义目录
        /// </summary>
        [EnumAttirbute("自定义目录")]
        AssetsCustomize = 4,
    }

    /// <summary>
    /// 打包 Android 、IOS 配置信息
    /// </summary>
    public class PackageConfig
    {
        // PackageConfig文件保存相对路径
        public PackageRelativePath FileRelativePath = PackageRelativePath.Assets;
        // PackageConfig文件保存路径
        public string filePath = "ProjectConfig/PackageConfig.json";

        public PackageRelativePath AppVersionRelativePath = PackageRelativePath.Assets;
        // 游戏版本号存储文件目录
        public string AppVersionPath = "ProjectConfig/AppVersion.txt";

        // iOS、Android 安装包以及工程导出目录，相对于哪个坐标
        public PackageRelativePath ExportRelationPath = PackageRelativePath.AssetsParent;
        // iOS、Android 安装包以及工程导出目录，最后会拼接上 平台路径
        public string Export = "Export";

        // 热更新程序 dll 放在项目中的位置，Assets 的子目录
        public string HotUpdateDllPath = "SubAssets/HotUpdateDLL";
        // 热更新程序 dll 文件名
        public string HotUpdateDllFileName = "HotUpdate.dll";

        // Xasset 哪些文件夹需要打包、以及文件夹打包的配置
        // 生成 Build 文件到目录 Assets/xasset
        public string XassetBuildConfigPath = "SubAssets/JsonAssets/XassetCfg.json";

        public KeystorePackageCfg keystoreCfg = new KeystorePackageCfg();
        public MaxPackageCfg maxPackageCfg = new MaxPackageCfg();
        public FacePackageCfg facePackageCfg = new FacePackageCfg();
        // 默认字体防止的文件夹
        public PackageRelativePath DefaultFontRelativePath = PackageRelativePath.Assets;
        public DefaultFont defaultFont = new DefaultFont();

        // XAsset CDN、Http 服务 Debug 地址信息
        public XAssetCloud xAssetCloudDebug = new XAssetCloud();
        // XAsset CDN、Http 服务 Distribute 地址信息
        public XAssetCloud xAssetCloudDistribute = new XAssetCloud();
    }

    /// <summary>
    /// Keystor 打包配置
    /// </summary>
    public class KeystorePackageCfg
    {
        #region Keystore 信息
        public PackageRelativePath keystoreRelativePath = PackageRelativePath.AssetsCustomize;
        public string keystorePath = "/Users/townest/NP_config/Keystore/HomeLand.keystore";
        public string keystorePass = "homeland@beijing";
        public string keyaliasName = "release_fairyadventure";
        public string keyaliasPass = "fairyadventure@0581";
        #endregion
    }

    /// <summary>
    /// Max SDK 打包配置
    /// </summary>
    public class MaxPackageCfg
    {
        #region Max
        public string SdkKey = "UKQHrUDpB6auE4BiHsDXET7pi6f_dUkiiGa8Uk3VWMxE1MzfmWsteO7mMNXmEdqR16i781ghwdCatJMvKoymC2";
        public string AdMobIDAndroid = "ca-app-pub-9835456922072969~5760526970";
        public string AdMobIDIOS = "ca-app-pub-9835456922072969~8195118628";
        #endregion

    }

    /// <summary>
    /// facebook SDK 打包配置
    /// </summary>
    public class FacePackageCfg
    {
        #region Facebook
        public string FacebookAppName = "fairyadventure";
        public string FacebookAppId = "936760714359043";
        public string FacebookClientToken = "e63ecdddd35153b782111a305ecf727b";
        #endregion
    }

    /// <summary>
    /// 默认字体地址
    /// </summary>  
    public class DefaultFont
    {
        public string DefaultFontPath = "SubAssets/Res/Fonts/English/GROBOLDSDF.asset";
    }

    /// <summary>
    /// XAsset CDN、Http 服务地址
    /// </summary>
    public class XAssetCloud
    {
        // 更新信息地址
        public string updateInfoURL = "http://10.0.252.20:9123/HttpServer/xassetCloud/UpdateLoad";
        // 下载地址
        public string downloadURL = "http://10.0.252.20:9123/HttpServer/xassetCloud/DownLoad";
    }
}
