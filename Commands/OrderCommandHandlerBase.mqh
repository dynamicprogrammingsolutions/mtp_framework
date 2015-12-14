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
      LISTEN(COrderCommand::CommandOpenBuy,0);
      LISTEN(COrderCommand::CommandOpenSell,1);
      LISTEN(COrderCommand::CommandCloseBuy,2);
      LISTEN(COrderCommand::CommandCloseSell,3);
      LISTEN(COrderCommand::CommandCloseAll,4);
   }
   
   virtual bool callback(const int i, CObject*& obj)
   {
      switch(i) {
         case 0: obj = OpenBuy(); break;
         case 1: obj = OpenSell(); break;
         case 2: CloseBuy(); break;
         case 3: CloseSell(); break;
         case 4: CloseAll(); break;
      }
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