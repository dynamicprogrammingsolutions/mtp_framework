//
#include "..\Loader.mqh"

#define ORDER_INTERFACE_H

#ifdef __MQL4__
#include "Enums\EnumOrderState.mqh"
#endif

#include "Enums\EnumExecuteState.mqh"
#include "Enums\EnumOrderSelect.mqh"
#include "Enums\EnumStateSelect.mqh"
#include "Enums\EnumActivity.mqh"

#define POrder shared_ptr<COrderInterface>
#define NewPOrder(__object__) POrder::make_shared(__object__)
#define MakeOrder(__object__) POrder::make_shared(__object__)

class COrderInterface : public CObservable
{
public:

   virtual int Id() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   
   virtual bool DoNotArchive() { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool DoNotDelete() { AbstractFunctionWarning(__FUNCTION__); return false; }
   
   virtual ENUM_ORDER_STATE State() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual ENUM_EXECUTE_STATE ExecuteState() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   
   virtual bool NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
   const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0) { AbstractFunctionWarning(__FUNCTION__); return false; }
   
   virtual void OnTick() { AbstractFunctionWarning(__FUNCTION__); return; }
      
   virtual bool Execute() { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool Close(double closevolume = 0, double closeprice = 0) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool Cancel() { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool Modify() { AbstractFunctionWarning(__FUNCTION__); return false; }

   virtual bool CreateAttached(ENUM_ORDER_TYPE _ordertype, double _volume, double _price, double _limit_price, string _name, string _comment) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool AddStopLoss(double in_price, double stopvolume = 0, string name = "") { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool AddTakeProfit(double in_price, double stopvolume = 0, string name = "") { AbstractFunctionWarning(__FUNCTION__); return false; } 

   virtual bool Closed() { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool Deleted() { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool ClosedOrDeleted() { AbstractFunctionWarning(__FUNCTION__); return false; }   
         
   virtual long GetTicket() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual int GetMagicNumber() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual string GetSymbol() { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual string GetComment() { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual ENUM_ORDER_TYPE GetType() { return NULL; }
   virtual datetime GetOpenTime() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual double GetOpenPrice() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual double GetLots() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual double GetClosePrice() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual datetime GetCloseTime() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual int GetStopLossTicks() { AbstractFunctionWarning(__FUNCTION__); return 0; }   
   virtual double GetStopLoss() { AbstractFunctionWarning(__FUNCTION__); return 0; }   
   virtual int GetTakeProfitTicks() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual double GetTakeProfit() { AbstractFunctionWarning(__FUNCTION__); return 0; }   
   virtual int GetProfitTicks() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual datetime GetExpiration() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual double GetProfitMoney() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual double GetCommission() { AbstractFunctionWarning(__FUNCTION__); return 0; }
   virtual double GetSwap() { AbstractFunctionWarning(__FUNCTION__); return 0; }

   virtual void SetOrderType(const ENUM_ORDER_TYPE value) { AbstractFunctionWarning(__FUNCTION__); }
   virtual void SetMagic(const int value) { AbstractFunctionWarning(__FUNCTION__); }
   virtual void SetSymbol(const string value) { AbstractFunctionWarning(__FUNCTION__); }
   virtual void SetComment(const string value) { AbstractFunctionWarning(__FUNCTION__); }
   virtual void SetLots(const double value) { AbstractFunctionWarning(__FUNCTION__); }
   virtual void SetExpiration(const datetime value) { AbstractFunctionWarning(__FUNCTION__); }
   virtual void SetPrice(const double value) { AbstractFunctionWarning(__FUNCTION__); }
   virtual void SetStopLoss(const double value) { AbstractFunctionWarning(__FUNCTION__); }
   virtual void SetTakeProfit(const double value) { AbstractFunctionWarning(__FUNCTION__); }
   virtual bool SetPrice(CStopsCalcInterface* _price, bool check = false) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool SetStopLoss(CStopsCalcInterface* _sl, bool checkchange = false, bool checkhigher = false) { AbstractFunctionWarning(__FUNCTION__); return false; }
   virtual bool SetTakeProfit(CStopsCalcInterface* _tp, bool check = false)  { AbstractFunctionWarning(__FUNCTION__); return false; }
   
#ifdef __MQL5__
   virtual void OnTradeTransaction(
      const MqlTradeTransaction&    trans,     // trade transaction structure 
      const MqlTradeRequest&        request,   // request structure 
      const MqlTradeResult&         result     // response structure 
   ) { AbstractFunctionWarning(__FUNCTION__); }
#endif
   
   
};