
class COrderCommandHandlerBase : public CCommandCallBackInterface
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
   
   virtual void Function(int id, CObject* obj)
   {
      HandleCommand(obj);
   }
   
   virtual void HandleCommand(CObject* command)
   {
      if (command.Type() == classOrderCommand) {
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