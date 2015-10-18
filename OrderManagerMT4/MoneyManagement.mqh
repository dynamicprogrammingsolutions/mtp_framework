//
#include "moneymanagement_helper.mqh"

class CMoneyManagement : public CAppObject {
public:
   virtual int Type() const { return classMT4MoneyManagement; }
   bool delete_after_use;
   virtual bool DeleteAfterUse() { return delete_after_use; }
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
   virtual double GetLotsize() {
      return lotsize;
   }
};

class CMoneyManagementExponential : public CMoneyManagement
{
public:   
   double lotsize;
   CMoneyManagement* mm;
   double level;
   double multiplier;
   double maximum_lotsize;
   CMoneyManagementExponential(CMoneyManagement* _mm, double _multiplier) {
      mm = _mm;
      multiplier = _multiplier;
   }
   CMoneyManagementExponential(double _lotsize, double _multiplier) {
      lotsize = _lotsize;
      multiplier = _multiplier;
   }
   virtual void SetLevel(double _level)
   {
      this.level = _level;
   }
   virtual double GetLotsize() {
      if (mm != NULL && (lotsize == 0 || level == 0)) lotsize = mm.SetStopLoss(this.stoploss).SetSymbol(this.symbol).GetLotsize();
      return maximum_lotsize > 0?MathMin(lotsize*MathPow(multiplier,level),maximum_lotsize):lotsize*MathPow(multiplier,level);
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
      moneymanagement_init(this.symbol);
      if (use_equity) accountbalance = accountequity;
      return mmgetlot_stoploss(stoploss.GetTicks(), riskpercent);
  }
};

class CMoneyManagementRiskMoney : public CMoneyManagement
{
public:
   double riskmoney;
   CMoneyManagementRiskMoney(double _riskmoney)
   {
      riskmoney = _riskmoney;
   }
   virtual double GetLotsize() {
      addaccountbalance = false;
      addfixbalance = riskmoney;
      moneymanagement_init(this.symbol);
      return mmgetlot_stoploss(stoploss.GetTicks(), 100);
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
      moneymanagement_init(this.symbol);
      if (use_equity) accountbalance = accountequity;
      return mmgetlot_ref_balance(lot, money);
  }
};
