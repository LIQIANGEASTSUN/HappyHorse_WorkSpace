using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Cookgame
{
    public interface ISystem
    {
        /// <summary>
        /// 系统初始化
        /// </summary>
        void InitSystem();
        /// <summary>
        /// 数据表准备就绪 可以处理配置相关数据
        /// </summary>
        void InitData();

        void DoUpdate();

        void DoFixedUpdate();

        void DoLateUpdate();
        /// <summary>
        /// 游戏结束 销毁
        /// </summary>
        void OnDispose();
    }
}
