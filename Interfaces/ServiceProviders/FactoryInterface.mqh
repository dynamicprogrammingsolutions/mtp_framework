//
#include "..\..\Loader.mqh"

class CFactoryInterface : public CServiceProvider
{
protected:
   virtual CAppObject* GetNewObject()
   {
      AbstractFunctionWarning(__FUNCTION__);   
      return NULL;
   }

public:
   virtual CAppObject* Create()
   {
      CAppObject* newobject = GetNewObject();
      Prepare(newobject);
      return newobject;
   }
};