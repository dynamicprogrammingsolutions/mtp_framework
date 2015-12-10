class COrderEventListener : public CAppObject
{
   virtual bool callback(const int id, CObject*& object)
   {
      COrder* order;
      if (id == COrderCommandHandlerBase::EventOpeningBuy) {
         Print("opening buy");
      }
      if (id == COrderCommandHandlerBase::EventOpenedBuy) {
         order = object;
         Print("opened buy: ",order.id);
      }
      if (id == COrderCommandHandlerBase::EventOpeningSell) {
         Print("opening sell");
      }
      if (id == COrderCommandHandlerBase::EventOpenedSell) {
         order = object;
         Print("opened sell: ",order.id);
      }
      return true;
   }
};

/*

Registering:
application.SetEventListener(srvOrderCommandHandler,new COrderEventListener());

*/