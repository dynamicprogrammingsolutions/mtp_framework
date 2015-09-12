//

#include "ServiceProvider.mqh"
#include "OrderBaseBase.mqh"

class COrderManagerBase : public CServiceProvider
{
   public:
      COrderManagerBase()
      {
         name = "ordermanager";
         srv = srvOrderManager;
      }
   
      virtual COrderBaseBase* NewOrderObject() { return NULL ; }
      virtual COrderBaseBase* NewAttachedOrderObject() { return NULL; }
};