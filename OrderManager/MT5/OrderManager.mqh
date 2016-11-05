//+------------------------------------------------------------------+
//|                                                 OrderManager.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//TODO: VPrice, Attached Order Virtual Capability
//Trailing Stop On Virtual Order
//Compare to MT5 version and port the modifications that are applicable there
//If removed or MT4 closed: handle the attached orders: cannot have attached SL if have hard SL.

#include "Loader.mqh"

#include "..\..\libraries\file.mqh"

#ifndef ORDER_MANAGER_H
#define ORDER_MANAGER_H
class COrderManager : public COrderManagerInterface
{
public:
   TraitGetType(classMT5OrderManager)
   TraitAppAccess
   TraitLoadSymbolFunction

   CAttachedOrderArray attachedorders;

   CAppObject* neworder;   
   
   COrderManager()
   {
   };

   COrderManager(CAppObject* _neworder)
   {
      delete neworder;
      NewOrderObject(_neworder);
   };
   
   ~COrderManager()
   {
      delete neworder;
   }
   
   
   void Initalize()
   {
      Prepare(GetPointer(attachedorders));
   }
   
   virtual void NewOrderObject(CAppObject* obj)
   {
      if (isset(neworder)) delete neworder;
      neworder = obj;
   }
      
   virtual COrderInterface* NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
      const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0);
   virtual COrderInterface* NewOrder(COrderInterface* _order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
                                    const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0);

   virtual COrderInterface* NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagementInterface* mm, CStopsCalcInterface* _price,
                                    CStopsCalcInterface* _stoploss, CStopsCalcInterface* _takeprofit,const string _comment="",const datetime _expiration=0);
   virtual COrderInterface* NewOrder(COrderInterface* _order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagementInterface* mm, CStopsCalcInterface* _price,
                                    CStopsCalcInterface* _stoploss, CStopsCalcInterface* _takeprofit,const string _comment="",const datetime _expiration=0);

   virtual COrderInterface* NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,PMoneyManagement &mm, PStopsCalc &_price,
                                    PStopsCalc &_stoploss, PStopsCalc &_takeprofit,const string _comment="",const datetime _expiration=0);
   virtual COrderInterface* NewOrder(POrder &_order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,PMoneyManagement &mm, PStopsCalc &_price,
                                    PStopsCalc &_stoploss, PStopsCalc &_takeprofit,const string _comment="",const datetime _expiration=0);
  
   virtual COrderInterface* NewOrderObject() { return this.App().NewObject(neworder); }
   virtual COrderInterface* NewAttachedOrderObject() { return App().GetDependency(classOrder,classAttachedOrder); }

};
   
int OriginalOrdersTotal()
{
   return OrdersTotal();
}

COrderInterface* COrderManager::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
                                 const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0)
{
   COrderInterface* _order = NewOrderObject();
   
   _order.NewOrder(in_symbol,_ordertype,_volume,_price,_stoploss,_takeprofit,_comment,_expiration);
   App().orderrepository.Add(_order);
   return(_order);
}

COrderInterface* COrderManager::NewOrder(COrderInterface* _order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
                                 const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0)
{
   
   _order.NewOrder(in_symbol,_ordertype,_volume,_price,_stoploss,_takeprofit,_comment,_expiration);
   App().orderrepository.Add(_order);
   return(_order);
}

COrderInterface* COrderManager::NewOrder(COrderInterface* _order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagementInterface* _mm,CStopsCalcInterface* _price,
                                 CStopsCalcInterface* _stoploss,CStopsCalcInterface* _takeprofit,const string _comment="",const datetime _expiration=0)
{
   App().symbolloader.LoadSymbol(in_symbol).RefreshRates();

   if (_price != NULL) {
      _price.SetOrderType(_ordertype).SetSymbol(in_symbol);
      _price.Reset();
   }
   
   if (_stoploss != NULL) {
      _stoploss.SetOrderType(_ordertype).SetSymbol(in_symbol).SetEntryPrice(_price != NULL ? _price.GetPrice() : 0);
      _stoploss.Reset();
      _stoploss.SetTakeProfit(_takeprofit);
   }
   if (_takeprofit != NULL) {
      _takeprofit.SetOrderType(_ordertype).SetSymbol(in_symbol).SetEntryPrice(_price != NULL ? _price.GetPrice() : 0);
      _takeprofit.Reset();
      _takeprofit.SetStopLoss(_stoploss);
   }
   
   _mm.SetSymbol(in_symbol).SetStopLoss(_stoploss).SetOrderType(_ordertype);

   _order.NewOrder(
      in_symbol,_ordertype,_mm.GetLotsize(),
      _price == NULL ? 0 : _price.GetPrice(),
      _stoploss == NULL ? 0 : _stoploss.GetPrice(),
      _takeprofit == NULL ? 0 : _takeprofit.GetPrice(),
      _comment,_expiration);
      
   App().orderrepository.Add(_order);

   return(_order);
}


COrderInterface* COrderManager::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagementInterface* _mm,CStopsCalcInterface* _price,
                                 CStopsCalcInterface* _stoploss,CStopsCalcInterface* _takeprofit,const string _comment="",const datetime _expiration=0)
{
   loadsymbol(in_symbol);
   _symbol.RefreshRates();
   COrderInterface* _order = NewOrderObject();
   NewOrder(_order, in_symbol, _ordertype,_mm,_price,_stoploss,_takeprofit,_comment,_expiration);
   return(_order);
}

COrderInterface* COrderManager::NewOrder(POrder &_order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,PMoneyManagement &_mm,PStopsCalc &_price,
                                 PStopsCalc &_stoploss,PStopsCalc &_takeprofit,const string _comment="",const datetime _expiration=0)
{
   App().symbolloader.LoadSymbol(in_symbol).RefreshRates();

   if (_price.get() != NULL) {
      _price.get().SetOrderType(_ordertype).SetSymbol(in_symbol);
      _price.get().Reset();
   }
   
   if (_stoploss.get() != NULL) {
      _stoploss.get().SetOrderType(_ordertype).SetSymbol(in_symbol).SetEntryPrice(_price.isset() ? _price.get().GetPrice() : 0);
      _stoploss.get().Reset();
      _stoploss.get().SetTakeProfit(_takeprofit);
   }
   if (_takeprofit.get() != NULL) {
      _takeprofit.get().SetOrderType(_ordertype).SetSymbol(in_symbol).SetEntryPrice(_price.isset() ? _price.get().GetPrice() : 0);
      _takeprofit.get().Reset();
      _takeprofit.get().SetStopLoss(_stoploss);
   }
   
   _mm.get().SetSymbol(in_symbol).SetStopLoss(_stoploss).SetOrderType(_ordertype);

   _order.get().NewOrder(
      in_symbol,_ordertype,_mm.get().GetLotsize(),
      !_price.isset() ? 0 : _price.get().GetPrice(),
      !_stoploss.isset() ? 0 : _stoploss.get().GetPrice(),
      !_takeprofit.isset() ? 0 : _takeprofit.get().GetPrice(),
      _comment,_expiration);
      
   App().orderrepository.Add(_order.get());

   return(_order.get());
}

COrderInterface* COrderManager::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,PMoneyManagement &_mm,PStopsCalc &_price,
                                 PStopsCalc &_stoploss,PStopsCalc &_takeprofit,const string _comment="",const datetime _expiration=0)
{
   loadsymbol(in_symbol);
   _symbol.RefreshRates();
   POrder _order = NewOrderObject();
   NewOrder(_order, in_symbol, _ordertype,_mm,_price,_stoploss,_takeprofit,_comment,_expiration);
   return(_order.get());
}


#endif