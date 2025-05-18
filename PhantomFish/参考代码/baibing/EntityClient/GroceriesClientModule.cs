namespace Cookgame.Entity
{
    public interface IGroceriesClientModule
    {
        //使用杂货
        // 0:不允许使用 1:客户端处理 2:服务器处理
        int UseGroceries(ulong uid);
    }

    public class GroceriesClientModule : IGroceriesClientModule
    {
        //使用杂货
        // 0:不允许使用 1:客户端处理 2:服务器处理
        public int UseGroceries(ulong uid)
        {
            //IPerson Master = ExternalFacadeModule.instance.GetHero();
            //if (Master  == null)
            //{
            //    return 0;
            //}
            //IGroceries Groceries = ExternalFacadeModule.instance.GetGroceries(uid);
            //if (Groceries == null)
            //{
            //    return 0;
            //}
            //propItemData ItemData = Groceries.GetItemData();
            //string Result;
            //if (!Groceries.CanUse(out Result))
            //{
            //    Debug.LogError("无法使用该物品,原因:"+ Result);
            //    //todo 广播到聊天栏
            //    return 0;
            //}
            //默认先到服务器处理
            return 2;

        }


    }
}
