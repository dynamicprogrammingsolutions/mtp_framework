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

   virtual void Send(int id, CObject* o = NULL, bool deleteobject = false)
   {
      if (id > 0) {
         CAppObject* callback = GetCallBack(id);
         callback.callback(id,o);
         if (deleteobject) delete o;
      }
      if (deleteobject) delete o;
   } 
   
};