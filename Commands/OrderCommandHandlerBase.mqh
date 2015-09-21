
class COrderCommandHandlerBase : public CServiceProvider
{
public:
   virtual int Type() const { return classOrderCommandHandlerBase; }

   COrderManager* ordermanager;
   
   virtual void Initalize()
   {
      this.ordermanager = this.App().GetService(srvOrderManager);
   }
   virtual void HandleCommand(CObject* command)
   {
      COrderCommand* ordercommand = command;
      switch (ordercommand.transaction_type) {
      	case ttOpen:
            switch (ordercommand.trade_direction) {
               case tdLong: OpenBuy(); break;
               case tdShort: OpenSell(); break;
            }
            break;
      	case ttClose:
            switch (ordercommand.trade_direction) {
               case tdLong: CloseBuy(); break;
               case tdShort: CloseSell(); break;
               case tdNone: CloseAll(); break;
            }
            break;
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