//

#include "..\Loader.mqh"

class CTriggerCallback : public CObject
{
public:
   CAppObject* callbackobj;
   int handler_id;
   bool Callback(CObject*& obj)
   {
      return callbackobj.callback(handler_id,obj);
   }
   CTriggerCallback(CAppObject* _callback, int _handler_id)
   {
      callbackobj = _callback;
      handler_id = _handler_id;
   }
};

class CTriggerManager : public CTriggerManagerInterface
{
public:
   TraitGetType(classTriggerManager)
   
public:
   CArrayObj container;
   
   virtual void Register(int& trigger_id, CAppObject* callback, int handler_id)
   {
      if (trigger_id == 0) {
         container.Add(new CArrayObj());
         trigger_id = container.Total();
      }
      CArrayObj* callbacks = GetCallBacks(trigger_id);
      callbacks.Add(new CTriggerCallback(callback,handler_id));
   }
   
   CArrayObj* GetCallBacks(const int id)
   {
      return container.At(id-1);
   }
      
   virtual bool Send(const int id)
   {
      CObject* o = NULL;
      bool ret = true;
      if (id > 0) {
         CArrayObj* callbacks = GetCallBacks(id);
         int total = callbacks.Total();
         for (int i = 0; i < callbacks.Total(); i++) {
            CTriggerCallback* callback = callbacks.At(i);
            ret &= callback.Callback(o);
         }
      }
      return ret;
   }   
      
   virtual bool Send(const int id, CObject*& o, const bool deleteobject = false)
   {
      CObject* originalobj;
      bool ret = true;
      if (id > 0) {
         CArrayObj* callbacks = GetCallBacks(id);
         originalobj = o;
         int total = callbacks.Total();
         for (int i = 0; i < callbacks.Total(); i++) {
            CTriggerCallback* callback = callbacks.At(i);
            o = originalobj;
            ret &= callback.Callback(o);
         }
      }
      if (deleteobject) delete o;
      return ret;
   }
   
   virtual bool SendR(const int id, CObject* o, const bool deleteobject = false)
   {
      CObject* originalobj;
      bool ret = true;
      if (id > 0) {
         CArrayObj* callbacks = GetCallBacks(id);
         originalobj = o;
         int total = callbacks.Total();
         for (int i = 0; i < callbacks.Total(); i++) {
            CTriggerCallback* callback = callbacks.At(i);
            o = originalobj;
            ret &= callback.Callback(o);
         }
      }
      if (deleteobject) delete o;
      return ret;
   }
   
};