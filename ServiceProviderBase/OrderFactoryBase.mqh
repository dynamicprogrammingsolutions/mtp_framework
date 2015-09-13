//
#include "..\Loader.mqh"

class COrderFactoryBase : public CServiceProvider
{
public:
   COrderFactoryBase()
   {
      srv = srvOrderFactory;
      name = "orderfactory";
   }
   virtual COrderBaseBase* NewOrderObject() { return NULL ; }
   virtual COrderBaseBase* NewAttachedOrderObject() { return NULL; }
};