//
#include "..\Loader.mqh"

class CAttachedOrderFactoryBase : public CFactoryBase
{
public:
   CAttachedOrderFactoryBase()
   {
      srv = srvAttachedOrderFactory;
      name = "attachedorderfactory";
   }
};