using System.Collections.Generic;
using Cookgame.Module;
using UnityEngine;

namespace Cookgame
{
    public class DataModuleSystem : ISystem
    {
        private Dictionary<int, IDataModule> _allDataModules;
        private List<IDataModule> _simpleModules;
        private List<IDataModule> _updateModules;

        private bool _isUpdating;
        private List<IDataModule> _adding;
        private List<IDataModule> _deling;

        public void InitSystem()
        {
            _allDataModules = new Dictionary<int, IDataModule>((int)DataModuleEnum.DataModuleCount);
            _simpleModules = new List<IDataModule>();
            _updateModules = new List<IDataModule>();
            _adding = new List<IDataModule>();
            _deling = new List<IDataModule>();
        }

        public void InitData()
        {
#if UNITY_EDITOR
            System.Type editorAssembliesClass = typeof(UnityEditor.AssetDatabase).Assembly.GetType("UnityEditor.EditorAssemblies");
            System.Reflection.MethodInfo subclassesOfMothod = editorAssembliesClass.GetMethod("SubclassesOf",
                System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.NonPublic);
            if (subclassesOfMothod != null)
            {
                var list = subclassesOfMothod.Invoke(editorAssembliesClass, new object[] { typeof(BaseModule) });
                if (list != null)
                {
                    List<string> allList = new List<string>();
                    var ator = ((System.Collections.IEnumerable)list).GetEnumerator();
                    while (ator.MoveNext())
                    {
                        if(ator.Current != null)
                            allList.Add(ator.Current.ToString());
                    }

                    int count = allList.Count;
                    foreach (var module in _allDataModules.Values)
                    {
                        allList.Remove(module.ToString());
                    }
                    GameLog.Log($"DataModuleSystem not Register Module <color=cyan>{_allDataModules.Count}/{count}</color>  {string.Join(" ' ", allList)}", Color.red);
                }
            }
#endif
            for (int i = 0; i < _simpleModules.Count; i++)
            {
                _simpleModules[i].InitData();
            }

            for (int i = 0; i < _updateModules.Count; i++)
            {
                _updateModules[i].InitData();
            }
        }

        public void DoUpdate()
        {
            _isUpdating = true;
            for (int index = 0; index < _updateModules.Count; index++)
            {
                if (_updateModules[index].IsActive)
                {
                    _updateModules[index].DoUpdate();
                }
            }

            _isUpdating = false;
            if (_adding.Count > 0)
            {
                for (int index = 0; index < _adding.Count; index++)
                {
                    if (_adding[index].IsNeedFrameUpdate)
                    {
                        _updateModules.Add(_adding[index]);
                    }
                    else
                    {
                        _simpleModules.Add(_adding[index]);
                    }
                }
                _adding.Clear();
            }
            if (_deling.Count > 0)
            {
                for (int index = 0; index < _deling.Count; index++)
                {
                    if (_deling[index].IsNeedFrameUpdate)
                        _updateModules.Remove(_deling[index]);
                    else
                        _simpleModules.Remove(_deling[index]);
                    _deling[index].Dispose();

                }
                _deling.Clear();
            }
        }

        public void DoFixedUpdate()
        {
            
        }

        public void DoLateUpdate()
        {
            
        }

        public void OnDispose()
        {
            foreach (var module in _allDataModules)
            {
                module.Value.Dispose();
            }
            _updateModules.Clear();
            _simpleModules.Clear();
            _adding.Clear();
            _deling.Clear();
        }

        public void RegisterModule(DataModuleEnum moduleEnum, IDataModule module)
        {
            RegisterModule((int) moduleEnum, module);
        }
        private void RegisterModule(int dataId, IDataModule module)
        {
            if (_allDataModules.ContainsKey(dataId))
            {
                GameLog.LogError("RegisterModule  is already has module " + dataId);
                return;
            }
            _allDataModules.Add(dataId, module);
            if (_isUpdating)
            {
                _adding.Add(module);
                return;
            }
            
            if (module.IsNeedFrameUpdate)
                _updateModules.Add(module);
            else
                _simpleModules.Add(module);
        }

        public void UnRegisterModule(IDataModule module)
        {
            if (_isUpdating)
            {
                _deling.Add(module);
                return;
            }
            if (module.IsNeedFrameUpdate && _updateModules.Contains(module))
            {
                _updateModules.Remove(module);
            }
            else if (!module.IsNeedFrameUpdate && _simpleModules.Contains(module))
            {
                _simpleModules.Remove(module);
            }
            module.Dispose();
        }

        public void UnRegisterModule(DataModuleEnum moduleEnum)
        {
            UnRegisterModule((int) moduleEnum);
        }

        private void UnRegisterModule(int dataId)
        {
            if (!_allDataModules.ContainsKey(dataId))
            {
                GameLog.LogWarning("UnRegisterModule  module but not register " + dataId);
                return;
            }

            IDataModule module = _allDataModules[dataId];
            _allDataModules.Remove(dataId);
            if (_isUpdating)
            {
                _deling.Add(module);
                return;
            }
            if (module.IsNeedFrameUpdate && _updateModules.Contains(module))
            {
                _updateModules.Remove(module);
            }
            else if (!module.IsNeedFrameUpdate && _simpleModules.Contains(module))
            {
                _simpleModules.Remove(module);
            }
            module.Dispose();
        }

        public IDataModule FindModule(DataModuleEnum moduleEnum)
        {
            IDataModule module;
            _allDataModules.TryGetValue((int)moduleEnum, out module);
            return module;
        }
    }
}
