//
#include "Loader.mqh"
#include "moneymanagement_helper.mqh"

#define MONEY_MANAGEMENT_H
class CMoneyManagement : public CMoneyManagementInterface {
private:
   //bool delete_after_use;   

public:
   TraitAppAccess
   TraitLoadSymbolFunction

   virtual int Type() const { return classMoneyManagement; }
   /*virtual bool DeleteAfterUse() { return delete_after_use; }
   void DeleteAfterUse(bool value) { delete_after_use = value; }*/
   //CMoneyManagement* UseOnce() { this.delete_after_use = true; return GetPointer(this); }

public:
   string symbol;
   PStopsCalc stoploss;
   ENUM_ORDER_TYPE ordertype;
   virtual CMoneyManagement* SetSymbol(string __symbol)
   {
      this.symbol = __symbol;
      return GetPointer(this);
   }
   virtual CMoneyManagement* SetStopLoss(CStopLoss* _stoploss)
   {
      stoploss.reset(_stoploss);
      return GetPointer(this);
   }
   virtual CMoneyManagement* SetStopLoss(PStopsCalc &_stoploss)
   {
      stoploss.assign(_stoploss);
      return GetPointer(this);
   }
   virtual CMoneyManagement* SetOrderType(ENUM_ORDER_TYPE _ordertype)
   {
      ordertype = _ordertype;
      return GetPointer(this);
   }
   virtual double GetLotsize() { return 0; }
};

/*class CLotsize : public CMoneyManagement
{
public:
   double lotsize;
   CLotsize(double _lotsize) {
      lotsize = _lotsize;
      //DeleteAfterUse(true);
   }
   virtual double GetLotsize() {
      return lotsize;
   }
};*/

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

class CMoneyManagementLevel : public CMoneyManagement
{
public:
   int level;
   virtual void SetLevel(int _level)
   {
      this.level = _level;
   }
   virtual void IncLevel()
   {
      this.level++;
   }
   virtual void DecLevel()
   {
      this.level--;
   }
};


class CMoneyManagementExponential : public CMoneyManagementLevel
{
public:   
   double lotsize;
   CMoneyManagement* mm;
   double multiplier;
   double maximum_lotsize;
   CMoneyManagementExponential()
   {
      
   }
   CMoneyManagementExponential(CMoneyManagement* _mm, double _multiplier, double in_maximum_lotsize = 0) {
      mm = _mm;
      multiplier = _multiplier;
      maximum_lotsize = in_maximum_lotsize;
   }
   CMoneyManagementExponential(double _lotsize, double _multiplier, double in_maximum_lotsize = 0) {
      lotsize = _lotsize;
      multiplier = _multiplier;
      maximum_lotsize = in_maximum_lotsize;
   }
   virtual double GetLotsize() {
      if (mm != NULL && (lotsize == 0 || level == 0)) lotsize = mm.SetStopLoss(this.stoploss).SetSymbol(this.symbol).GetLotsize();
      return maximum_lotsize > 0?MathMin(lotsize*MathPow(multiplier,level),maximum_lotsize):lotsize*MathPow(multiplier,level);
   }
};

class CMoneyManagementLotList : public CMoneyManagementLevel
{
public:
   double lotlist[];
   CMoneyManagementLotList()
   {
      
   }
   CMoneyManagementLotList(string mm_lotlist)
   {
      str_explode_double(mm_lotlist,lotlist,",");
   }
   void IncLevel()
   {
      level++;
      level = MathMin(level,ArraySize(lotlist)-1);
   }
   void DecLevel()
   {
      level--;
      level = MathMax(level,0);
   }
   virtual double GetLotsize() {
      
      return lotlist[level];
   }
};

class CMoneyManagementRiskPercent : public CMoneyManagement
{
public:
   bool use_equity;
   double riskpercent;
   CMoneyManagementRiskPercent() {}
   CMoneyManagementRiskPercent(double _riskpercent)
   {
      riskpercent = _riskpercent;
   }
   virtual double GetLotsize() {
      moneymanagement_init(this.symbol);
      if (use_equity) accountbalance = accountequity;
      if (stoploss.isnset()) {
         Print("Stoploss is not set in moneymanagement");
         return 0;
      }
      return mmgetlot_stoploss((int)stoploss.get().GetTicks(), riskpercent);
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
      if (stoploss.isnset()) {
         Print("Stoploss is not set in moneymanagement");
         return 0;
      }
      return mmgetlot_stoploss((int)stoploss.get().GetTicks(), 100);
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
