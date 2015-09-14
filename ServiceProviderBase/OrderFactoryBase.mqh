//
#include "..\Loader.mqh"

class COrderFactoryBase : public CFactoryBase
{
public:
   COrderFactoryBase()
   {
      srv = srvOrderFactory;
      name = "orderfactory";
   }
};