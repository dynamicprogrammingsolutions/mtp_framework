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
      The callback should return true if the command is handled right, in that case no further handlers will be called.
   */

   virtual CObject* Send(int id, CObject* o = NULL, bool deleteobject = false)
   {
      CObject* originalobj;
      if (id > 0) {
         CArrayObj* callbacks = GetCallBacks(id);
         originalobj = o;
         int total = callbacks.Total();
         for (int i = 0; i < callbacks.Total(); i++) {
            CAppObject* callback = callbacks.At(i);
            if (callback.callback(id,o)) break;
            o = originalobj;
         }
      }
      if (deleteobject) delete o;
      return o;
   } 
   
};