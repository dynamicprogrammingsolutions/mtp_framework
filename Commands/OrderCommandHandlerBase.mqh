
class COrderCommandHandlerBase : public CServiceProvider
{
public:
   COrderManager* ordermanager;
   virtual void Initalize()
   {
      this.ordermanager = this.App().GetService(srvOrderManager);
   }
   virtual void HandleCommand(CObject* command)
   {
      switch (command.Type()) {
         case classOpenBuy: OpenBuy(); break;
         case classOpenSell: OpenSell(); break;
         case classCloseBuy: CloseBuy(); break;
         case classCloseSell: CloseSell(); break;
      }
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