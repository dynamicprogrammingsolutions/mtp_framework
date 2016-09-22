//
#include "..\..\Loader.mqh"

class COrderRepositoryInterface : public CServiceProvider
{
public:
   virtual COrderInterface* Selected() { return NULL; }

   virtual void Add(COrderInterface* order) { }
   
   virtual int Total() { return 0; }
   virtual int HistoryTotal() { return 0; }

   virtual COrderInterface* GetByIdx(int idx) { return NULL; }
   virtual COrderInterface* GetHistoryByIdx(int idx) { return NULL; }

   virtual int GetIdxByTicket(int ticket) { return 0; }
   virtual int GetIdxByTicketHistory(int ticket) { return 0; }

   virtual COrderInterface* GetByTicketOrder(uint ticket) { return NULL; }
   virtual COrderInterface* GetByTicketHistory(uint ticket) { return NULL; }
   virtual COrderInterface* GetByTicket(int ticket) { return NULL; }
   virtual COrderInterface* GetById(int id) { return NULL; }
   
   virtual bool SelectByIdxOrder(int idx) { return false; }
   virtual bool SelectByIdxHistory(int idx) { return false; }   
   virtual bool SelectByTicketOrder(uint ticket) { return false; }
   
   virtual bool GetOrders(ENUM_ORDERSELECT type = ORDERSELECT_ANY, ENUM_STATESELECT state = STATESELECT_ANY, string in_symbol = "", int in_magic = -1, bool no_loop_and_reset = false)
   {
      return false;
   }
   
   virtual bool CloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1) { return false; }
   virtual bool CloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect, string in_symbol, int in_magic, CAppObject*)  { return false; }
   virtual int CntOrders(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)  { return 0; }

   virtual double AvgPrice(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)  { return 0; }
   virtual double TotalLots(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)  { return 0; }
   virtual double TotalProfit(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)  { return 0; }
   virtual double TotalProfitMoney(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1, bool _commission = true, bool swap = true)  { return 0; }
   
};