
class COrderCommandHandlerBase : public CServiceProvider
{
public:
   virtual int Type() const { return classOrderCommandHandlerBase; }

   TraitAppAccess

   COrderManager* ordermanager;
   
   virtual void Initalize()
   {
      this.ordermanager = this.App().GetService(srvOrderManager);
      this.App().commandmanager.Register(COrderCommand::Command,GetPointer(this));
   }
   
   virtual void callback(int i)
   {
      switch (i) {
      	case commandOpenBuy: OpenBuy(); break;
      	case commandOpenSell: OpenSell(); break;
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