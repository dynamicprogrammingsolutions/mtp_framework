//
#include "..\Loader.mqh"

class CCommandManager : public CCommandManagerInterface
{
public:
   TraitGetType { return classCommandManager; }
   
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
         CAppObject* callback = container.At(id-1);
         return callback;
      }
      return NULL;
   }
   
   virtual CAppObject* Send(int id)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         callback.callback(id);
         return callback;
      }
      return NULL;
   }    
   
   virtual CAppObject* Send(int id, int i)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         callback.callback(i);
         return callback;
      }
      return NULL;
   } 

   virtual CAppObject* Send(int id, bool b)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         callback.callback(b);
         return callback;
      }
      return NULL;
   } 

   virtual CAppObject* Send(int id, double d)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         callback.callback(d);
         return callback;
      }
      return NULL;
   } 
   
   virtual CAppObject* Send(int id, CObject* o = NULL, bool deleteobject = false)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         callback.callback(o);
         if (deleteobject) delete o;
         return callback;
      }
      if (deleteobject) delete o;
      return NULL;
   } 

   
};