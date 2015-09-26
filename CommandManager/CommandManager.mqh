//
#include "..\Loader.mqh"

class CCommandManager : public CCommandManagerInterface
{
public:
   TraitGetType { return classCommandManager; }
   
public:
   CArrayObj container;
  
   virtual void Register(int& id, CCallBackInterface* callback)
   {
      container.Add(callback);
      id = container.Total();
   }
   
   virtual void Send(int id, CObject* object = NULL, bool deleteobject = false)
   {
      if (id > 0) {
         CCallBackInterface* callback = container.At(id-1);
         callback.Function(id,object);
      }
      if (deleteobject) delete object;
   } 

   virtual CObject* SendRetObj(int id, CObject* object = NULL, bool deleteobject = false)
   {
      CObject* ret = NULL;
      if (id > 0) {
         CCallBackInterface* callback = container.At(id-1);
         ret = callback.FunctionRetObj(id,object);
      }
      if (deleteobject) delete object;
      return ret;
   } 

   virtual bool SendRetBool(int id, CObject* object = NULL, bool defaultreturn = true, bool deleteobject = false)
   {
      bool ret = defaultreturn;
      if (id > 0) {
         CCallBackInterface* callback = container.At(id-1);
         ret = callback.FunctionRetBool(id,object);
      }
      if (deleteobject) delete object;
      return ret;
   }
   
};