//
#include "..\Loader.mqh"

class CEventManager : public CEventManagerInterface
{
public:
   TraitGetType { return classEventManager; }
   
public:
   CArrayObj container;
  
   virtual void Register(int& id, CAppObject* callback)
   {
      if (id == 0) {
         container.Add(new CArrayObj());
         id = container.Total();
      }
      CArrayObj* callbacks = GetCallBacks(id);
      callbacks.Add(callback);
   }
   
   CArrayObj* GetCallBacks(int id)
   {
      return container.At(id-1);
   }
   
   /*
      Callback should return bool for events triggered before an action, and should be true if the action is endabled.
   */
   
   virtual bool Send(int id, CObject* o = NULL, bool deleteobject = false)
   {
      CObject* originalobj;
      bool ret = true;
      if (id > 0) {
         CArrayObj* callbacks = GetCallBacks(id);
         originalobj = o;
         int total = callbacks.Total();
         for (int i = 0; i < callbacks.Total(); i++) {
            CAppObject* callback = callbacks.At(i);
            ret &= callback.callback(id,o);
            o = originalobj;
         }
      }
      if (deleteobject) delete o;
      return ret;
   }
   
};