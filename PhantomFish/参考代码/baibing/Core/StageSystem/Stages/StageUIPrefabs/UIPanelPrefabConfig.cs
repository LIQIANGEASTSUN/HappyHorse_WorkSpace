using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Cookgame
{
    public class UIPanelPrefabConfig
    {
        private int mUIID;
        private string mRootName;
        private bool mDefaultVisible = true;
        private bool mIsAutoDestroy = false;
        private bool mIsSingle = true;
        private System.Type mTypeT = null;
        private List<string> depend;

        public System.Type TypeT
        {
            get { return mTypeT; }
            set { mTypeT = value; }
        }
        public string RootName
        {
            get { return mRootName; }
            set { mRootName = value; }
        }

        public int UiId
        {
            get { return mUIID; }
            set { mUIID = value; }
        }

        public bool DefaultVisible
        {
            get { return mDefaultVisible; }
            set { mDefaultVisible = value; }
        }

        public bool IsAutoDestroy
        {
            get { return mIsAutoDestroy; }
            set { mIsAutoDestroy = value; }
        }
        public bool IsSingle
        {
            get { return mIsSingle; }
            set { this.mIsSingle = value; }
        }

        public List<string> Depend
        {
            get { return depend; }
            set { depend = value; }
        }
    }
}
