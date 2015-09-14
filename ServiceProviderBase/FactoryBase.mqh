//
#include "..\Loader.mqh"

class CFactoryBase : public CServiceProvider
{
protected:
   virtual CAppObject* GetNewObject()
   {
      Print("Calling Abstract Function In: ",EnumToString((ENUM_CLASS_NAMES)this.Type()));
      return NULL;
   }
   virtual void Prepare(CAppObject* obj)
   {
      if (CheckPointer(obj) == POINTER_INVALID) {
         Print("invalid pointer in factory: ",EnumToString((ENUM_CLASS_NAMES)this.Type()));
         return;
      }
      obj.app = this.app;
   }

public:
   virtual CAppObject* Create()
   {
      CAppObject* newobject = GetNewObject();
      Prepare(newobject);
      return newobject;
   }
};