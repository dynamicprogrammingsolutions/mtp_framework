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
      container.Add(callback);
      id = container.Total();
   }
   
   virtual CAppObject* GetCallBack(int id)
   {
      if (id > 0) {
         return container.At(id-1);
      }
      return NULL;
   }
   
   virtual void Send(int id)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         callback.callback(id);
      }
   }    
   
   virtual void Send(int id, int i)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         callback.callback(id,i);
      }
   } 

   virtual void Send(int id, bool b)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         callback.callback(id,b);
      }
   } 

   virtual void Send(int id, double d)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         callback.callback(id,d);
      }
   } 
   
   virtual void Send(int id, CObject* o = NULL, bool deleteobject = false)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         callback.callback(id,o);
         if (deleteobject) delete o;
      }
      if (deleteobject) delete o;
   } 
   
   virtual bool SendB(int id, bool def = true)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         return callback.callback_b(id);
      }
      return def;
   }    
   
   virtual bool SendB(int id, int i, bool def = true)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         return callback.callback_b(id,i);
      }
      return def;
   } 

   virtual bool SendB(int id, bool b, bool def = true)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         return callback.callback_b(id,b);
      }
      return def;
   } 

   virtual bool SendB(int id, double d, bool def = true)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         return callback.callback_b(id,d);
      }
      return def;
   } 
   
   virtual bool SendB(int id, CObject* o = NULL, bool def = true, bool deleteobject = false)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         bool ret = callback.callback_b(id,o);
         if (deleteobject) delete o;
         return ret;
      }
      if (deleteobject) delete o;
      return def;
   } 
   
};