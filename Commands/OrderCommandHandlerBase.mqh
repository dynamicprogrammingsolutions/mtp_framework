#include "..\Loader.mqh"

class COrderCommandHandlerBase : public CServiceProvider
{
public:
   virtual int Type() const { return classOrderCommandHandlerBase; }

   TraitAppAccess

   COrderManager* ordermanager;
   
   static int EventOpeningBuy;
   static int EventOpeningSell;
   
   virtual void Initalize()
   {
      this.ordermanager = this.App().GetService(srvOrderManager);
      this.App().commandmanager.Register(COrderCommand::Command,GetPointer(this));
   }
   
   virtual void callback(int i1, int i2)
   {
      switch (i2) {
      	case commandOpenBuy: /*App().eventmanager.Send(EventOpeningBuy);*/ OpenBuy(); break;
      	case commandOpenSell: /*App().eventmanager.Send(EventOpeningSell);*/ OpenSell(); break;
      	case commandCloseBuy: CloseBuy(); break;
      	case commandCloseSell: CloseSell(); break;
      	case commandCloseAll: CloseAll(); break;
      }
      
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