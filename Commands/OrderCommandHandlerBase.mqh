#include "..\Loader.mqh"

class COrderCommandHandlerBase : public CServiceProvider
{
public:
   virtual int Type() const { return classOrderCommandHandlerBase; }

   TraitAppAccess

   virtual void Initalize()
   {
      LISTEN(COrderCommand::CommandOpenBuy,1);
      LISTEN(COrderCommand::CommandOpenSell,2);
      LISTEN(COrderCommand::CommandCloseBuy,3);
      LISTEN(COrderCommand::CommandCloseSell,4);
      LISTEN(COrderCommand::CommandCloseAll,5);
   }
   
   CALLBACK(
      CBFUNC(1,CommandOpenBuy)
      CBFUNC(2,CommandOpenSell)
      CBFUNC(3,CommandCloseBuy)
      CBFUNC(4,CommandCloseSell)
      CBFUNC(5,CommandCloseAll)
   )
   
   virtual bool CommandCloseAll(CObject*& obj)
   {
      return true;
   }

   virtual bool CommandCloseBuy(CObject*& obj)
   {
      return true;
   }
   
   virtual bool CommandCloseSell(CObject*& obj)
   {
      return true;
   }
   
   virtual bool CommandOpenBuy(CObject*& obj)
   {
      return true;
   }
   
   virtual bool CommandOpenSell(CObject*& obj)
   {
      return true;
   }
   
   
};