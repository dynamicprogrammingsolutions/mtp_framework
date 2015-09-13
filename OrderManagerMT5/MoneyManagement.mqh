//
#include "moneymanagement_helper.mqh"
#include "..\OrderManager\StopsCalc.mqh"

class CMoneyManagement : public CObject {
public:
   string symbol;
   CStopLoss* stoploss;
   virtual CMoneyManagement* SetSymbol(string __symbol)
   {
      this.symbol = __symbol;
      return GetPointer(this);
   }
   virtual CMoneyManagement* SetStopLoss(CStopLoss* _stoploss)
   {
      stoploss = _stoploss;
      return GetPointer(this);
   }
   virtual double GetLotsize() { return 0; }
};

class CMoneyManagementFixed : public CMoneyManagement
{
public:
   double lotsize;
   CMoneyManagementFixed(double _lotsize) {
      lotsize = _lotsize;
   }
   virtual CMoneyManagement* SetStopLoss(CStopLoss* _stoploss)
   {      
      return GetPointer(this);
   }
   virtual double GetLotsize() {
      return lotsize;
   }
};

class CMoneyManagementRiskPercent : public CMoneyManagement
{
public:
   bool use_equity;
   double riskpercent;
   CMoneyManagementRiskPercent(double _riskpercent)
   {
      riskpercent = _riskpercent;
   }
   virtual double GetLotsize() {
      loadsymbol(this.symbol,__FUNCTION__);
      moneymanagement_init();
      if (use_equity) accountbalance = accountequity;
      return mmgetlot_stoploss(stoploss.GetTicks(), riskpercent);
  }
};

class CMoneyManagementLotPerMoney : public CMoneyManagement
{
public:
   bool use_equity;
   double lot;
   double money;
   CMoneyManagementLotPerMoney(double _lot, double _money)
   {
      lot = _lot;
      money = _money;
   }
   virtual double GetLotsize() {
      moneymanagement_init();
      if (use_equity) accountbalance = accountequity;
      return mmgetlot_ref_balance(lot, money);
  }
};
