#include "..\Loader.mqh"

class COrderCommandHandlerBase : public CServiceProvider
{
public:
   virtual int Type() const { return classOrderCommandHandlerBase; }

   TraitAppAccess

   COrderManager* ordermanager;
   
   static int EventOpeningBuy;
   static int EventOpeningSell;

   static int EventOpenedBuy;
   static int EventOpenedSell;
   
   virtual void Initalize()
   {
      this.ordermanager = this.App().GetService(srvOrderManager);
      this.App().commandmanager.Register(COrderCommand::CommandOpenBuy,GetPointer(this));
      this.App().commandmanager.Register(COrderCommand::CommandOpenSell,GetPointer(this));
      this.App().commandmanager.Register(COrderCommand::CommandCloseBuy,GetPointer(this));
      this.App().commandmanager.Register(COrderCommand::CommandCloseSell,GetPointer(this));
      this.App().commandmanager.Register(COrderCommand::CommandCloseAll,GetPointer(this));
   }
   
   virtual void callback(int i)
   {
      if (i == COrderCommand::CommandOpenBuy) OpenBuy();
      if (i == COrderCommand::CommandOpenSell) OpenSell();
      if (i == COrderCommand::CommandCloseBuy) CloseBuy();
      if (i == COrderCommand::CommandCloseSell) CloseSell();
      if (i == COrderCommand::CommandCloseAll) CloseAll();
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
   
   virtual void OpenBuy()
   {

   }
   
   virtual void OpenSell()
   {

   }
};

int COrderCommandHandlerBase::EventOpeningBuy = 0;
int COrderCommandHandlerBase::EventOpeningSell = 0;
int COrderCommandHandlerBase::EventOpenedBuy = 0;
int COrderCommandHandlerBase::EventOpenedSell = 0;