//
#include "..\Loader.mqh"

class CFactoryBase : public CServiceProvider
{
protected:
   virtual CAppObject* GetNewObject()
   {
      return NULL;
   }

public:
   virtual CAppObject* Create()
   {
      CAppObject* newobject = GetNewObject();
      newobject.app = this.app;
      return newobject;
   }
};