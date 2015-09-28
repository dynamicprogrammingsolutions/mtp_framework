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
   
   virtual bool callback(const int i, CObject*& obj)
   {
      if (i == COrderCommand::CommandOpenBuy) obj = OpenBuy();
      else if (i == COrderCommand::CommandOpenSell) obj = OpenSell();
      else if (i == COrderCommand::CommandCloseBuy) CloseBuy();
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
   
   virtual COrder* OpenBuy()
   {
      return NULL;
   }
   
   virtual COrder* OpenSell()
   {
      return NULL;
   }
   
   
};

int COrderCommandHandlerBase::EventOpeningBuy = 0;
int COrderCommandHandlerBase::EventOpeningSell = 0;
int COrderCommandHandlerBase::EventOpenedBuy = 0;
int COrderCommandHandlerBase::EventOpenedSell = 0;