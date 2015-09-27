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
   
   virtual void Send(int id)
   {
      if (id > 0) {
         CArrayObj* callbacks = GetCallBacks(id);
         int total = callbacks.Total();
         for (int i = 0; i < callbacks.Total(); i++) {
            CAppObject* callback = callbacks.At(i);
            callback.callback(id);
         }
      }
   }    
   
   virtual void Send(int id, CObject* o = NULL, bool deleteobject = false)
   {
      if (id > 0) {
         CArrayObj* callbacks = GetCallBacks(id);
         int total = callbacks.Total();
         for (int i = 0; i < callbacks.Total(); i++) {
            CAppObject* callback = callbacks.At(i);
            callback.callback(id,o);
         }
         if (deleteobject) delete o;
      }
      if (deleteobject) delete o;
   }
   
   virtual bool SendB(int id)
   {
      if (id > 0) {
         CArrayObj* callbacks = GetCallBacks(id);
         int total = callbacks.Total();
         bool ret = true;
         for (int i = 0; i < callbacks.Total(); i++) {
            CAppObject* callback = callbacks.At(i);
            ret &= callback.callback_b(id);
         }
      }
      return ret;
   }
   
};