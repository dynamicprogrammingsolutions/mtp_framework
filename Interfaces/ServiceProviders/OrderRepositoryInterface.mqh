//
#include "..\..\Loader.mqh"

#define ORDER_REPOSITORY_INTERFACE_H
class COrderRepositoryInterface : public CServiceProvider
{
public:
   virtual COrderInterface* Selected() { AbstractFunctionWarning(__FUNCTION__); return NULL; }

   virtual void Add(COrderInterface* order) {AbstractFunctionWarning(__FUNCTION__); }
   
   virtual int Total() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual int HistoryTotal() { AbstractFunctionWarning(__FUNCTION__); return 0; }

   virtual COrderInterface* GetByIdx(int idx) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual COrderInterface* GetHistoryByIdx(int idx) { AbstractFunctionWarning(__FUNCTION__); return NULL; }

   virtual int GetIdxByTicket(int ticket) { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual int GetIdxByTicketHistory(int ticket) { AbstractFunctionWarning(__FUNCTION__); return 0; }

   virtual COrderInterface* GetByTicketOrder(uint ticket) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual COrderInterface* GetByTicketHistory(uint ticket) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual COrderInterface* GetByTicket(int ticket) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual COrderInterface* GetById(int id) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   
   virtual bool SelectByIdxOrder(int idx) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool SelectByIdxHistory(int idx) { AbstractFunctionWarning(__FUNCTION__); return false; }   
   virtual bool SelectByTicketOrder(uint ticket) { AbstractFunctionWarning(__FUNCTION__); return false; }
   
   virtual bool GetOrders(ENUM_ORDERSELECT type = ORDERSELECT_ANY, ENUM_STATESELECT state = STATESELECT_ANY, string in_symbol = "", int in_magic = -1, bool no_loop_and_reset = false)
   {
      AbstractFunctionWarning(__FUNCTION__); return false;
   }
   
   virtual bool CloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool CloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect, string in_symbol, int in_magic, CAppObject*)  { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual int CntOrders(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)  { AbstractFunctionWarning(__FUNCTION__); return 0; }

   virtual double AvgPrice(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)  { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual double TotalLots(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)  { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual double TotalProfit(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1)  { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual double TotalProfitMoney(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING, string in_symbol = "", int in_magic = -1, bool _commission = true, bool swap = true)  { AbstractFunctionWarning(__FUNCTION__); return 0; }
   
};