#include "..\Loader.mqh"

class COrderCommandHandlerBase : public CServiceProvider
{
public:
   virtual int Type() const { return classOrderCommandHandlerBase; }

   TraitAppAccess

   COrderManager* ordermanager;
   
   virtual void Initalize()
   {
      this.ordermanager = this.App().GetService(srvOrderManager);      
   }
   
   virtual bool callback(const int i, CObject*& obj)
   {
      if (i == COrderCommand::CommandOpenBuy) {
         obj = OpenBuy();
      } else if (i == COrderCommand::CommandOpenSell) {
         obj = OpenSell();
      } else if (i == COrderCommand::CommandCloseBuy) CloseBuy();
      else if (i == COrderCommand::CommandCloseSell) CloseSell();
      else if (i == COrderCommand::CommandCloseAll) CloseAll();
      else return false;
      
      return true;
   }

   virtual void CloseAll()
   {

   }

   virtual void CloseBuy()
   {

   }
   
   virtual void CloseSell()
   {

   }
   
   virtual CObject* OpenBuy()
   {
      return NULL;
   }
   
   virtual CObject* OpenSell()
   {
      return NULL;
   }
   
   
};