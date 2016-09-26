#include "..\Loader.mqh"

class CDependencyItem : public CArrayObj
{
public:
   ENUM_CLASS_NAMES caller;
   ENUM_CLASS_NAMES dependency;
   CAppObject* callback;
   
   CDependencyItem(ENUM_CLASS_NAMES _caller,
   ENUM_CLASS_NAMES _dependency)
   {
      caller = _caller;
      dependency = _dependency;
   }
};

class CDependencyManager : public CDependencyManagerInterface
{
public:
   TraitGetType(classDependencyManager)

   int FindDependency(ENUM_CLASS_NAMES caller, ENUM_CLASS_NAMES dependency)
   {
      for (int i = 0; i < Total(); i++) {
         CDependencyItem* dependencyitem = At(i);
         if (caller == dependencyitem.caller && dependency == dependencyitem.dependency) {
            return i;
         }
      }
      return -1;
   }

   virtual void SetDependency(ENUM_CLASS_NAMES caller, ENUM_CLASS_NAMES dependency, CAppObject* callback)
   {
      int idx = FindDependency(caller,dependency);
      if (idx < 0) {
         this.Add(new CDependencyItem(caller,dependency));
         idx = this.Total()-1;
      }
      CDependencyItem* item = At(idx);
      item.callback = callback;
   }
   
   virtual CAppObject* GetDependency(ENUM_CLASS_NAMES caller, ENUM_CLASS_NAMES dependency)
   {
      int idx = FindDependency(caller,dependency);
      if (idx < 0) {
         Print("dependency ",EnumToString(dependency)," not found for "+EnumToString(caller));
         return NULL;
      }
      CDependencyItem* item = At(idx);
      CAppObject* callback = item.callback;
      CAppObject* obj;
      callback.callback(0,obj);
      Prepare(obj);
      return obj;
   }
   
   virtual bool DependencyIsSet(ENUM_CLASS_NAMES caller, ENUM_CLASS_NAMES dependency)
   {
      int idx = FindDependency(caller,dependency);
      return idx >= 0;
   }
};