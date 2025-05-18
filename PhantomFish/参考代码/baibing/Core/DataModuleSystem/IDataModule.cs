
namespace Cookgame
{
    public interface IDataModule
    {
        void InitData();

        bool IsNeedFrameUpdate { get; }

        bool IsActive { get; }

        void Dispose();

        void DoUpdate();
    }
}