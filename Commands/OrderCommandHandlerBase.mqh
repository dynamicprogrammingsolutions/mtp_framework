#include "..\Loader.mqh"

class COrderCommandHandlerBase : public CServiceProvider
{
public:
   virtual int Type() const { return classOrderCommandHandlerBase; }

   TraitAppAccess
   TraitHasEvents

   static int EventOpeningBuy;
   static int EventOpeningSell;
   static int EventOpenedBuy;
   static int EventOpenedSell;
      
   void GetEvents(int& events[])
   {
     int i = 0;
     ArrayResize(events,4);
     events[i++] = EventId(EventOpeningBuy);
     events[i++] = EventId(EventOpeningSell);
     events[i++] = EventId(EventOpenedBuy);
     events[i++] = EventId(EventOpenedSell);
   }

   COrderManager* ordermanager;
   
   virtual void Initalize()
   {
      this.ordermanager = this.App().GetService(srvOrderManager);      
   }
   
   virtual bool callback(const int i, CObject*& obj)
   {
      if (i == COrderCommand::CommandOpenBuy) {
         if (EventSend(EventOpeningBuy)) { obj = OpenBuy(); EventSend(EventOpenedBuy,obj); }
      } else if (i == COrderCommand::CommandOpenSell) {
         if (EventSend(EventOpeningSell)) { obj = OpenSell(); EventSend(EventOpenedSell); }
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