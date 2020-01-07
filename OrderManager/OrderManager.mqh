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

#include "..\libraries\file.mqh"

#ifndef ORDER_MANAGER_H
#define ORDER_MANAGER_H
class COrderManager : public COrderManagerInterface
{
public:
   TraitGetType(classOrderManager)
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
   virtual COrderInterface* NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagementInterface* mm, CMoneyManagementInterface*& _mm_ptp[], CStopsCalcInterface* _price,
                                    CStopsCalcInterface* _stoploss, CStopsCalcInterface* _takeprofit, CStopsCalcInterface*& _ptps[],const string _comment="",const datetime _expiration=0);
   virtual COrderInterface* NewOrder(COrderInterface* _order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagementInterface* mm, CStopsCalcInterface* _price,
                                    CStopsCalcInterface* _stoploss, CStopsCalcInterface* _takeprofit,const string _comment="",const datetime _expiration=0);
   virtual COrderInterface* NewOrder(COrderInterface* _order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagementInterface* mm, CMoneyManagementInterface*& _mm_ptp[], CStopsCalcInterface* _price,
                                    CStopsCalcInterface* _stoploss, CStopsCalcInterface* _takeprofit, CStopsCalcInterface*& _ptps[],const string _comment="",const datetime _expiration=0);

   virtual COrderInterface* NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,PMoneyManagement &mm, PStopsCalc &_price,
                                    PStopsCalc &_stoploss, PStopsCalc &_takeprofit,const string _comment="",const datetime _expiration=0);
   virtual COrderInterface* NewOrder(POrder &_order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,PMoneyManagement &mm, PStopsCalc &_price,
                                    PStopsCalc &_stoploss, PStopsCalc &_takeprofit,const string _comment="",const datetime _expiration=0);
  
   virtual COrderInterface* NewOrderObject() { return this.App().NewObject(neworder); }
   virtual COrderInterface* NewAttachedOrderObject() { return App().GetDependency(classOrder,classAttachedOrder); }

#ifdef __MQL4__
   bool ExistingOrder(int ticket, COrderBase* orderbase, COrderBase* _order, COrderBase* attachedorder);
   COrder* ExistingOrder(int ticket, bool add = true);
   void AssignAttachedOrders(bool remove_if_not_found = true);
   int LoadOpenOrders(string __symbol, int __magic);
#endif
   
};
   
int OriginalOrdersTotal()
{
   return OrdersTotal();
}

COrderInterface* COrderManager::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
                                 const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0)
{
   COrderInterface* _order = NewOrderObject();
   
   App().orderrepository.Add(_order);
   _order.NewOrder(in_symbol,_ordertype,_volume,_price,_stoploss,_takeprofit,_comment,_expiration);
   
   return(_order);
}

COrderInterface* COrderManager::NewOrder(COrderInterface* _order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
                                 const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0)
{
   App().orderrepository.Add(_order);
   _order.NewOrder(in_symbol,_ordertype,_volume,_price,_stoploss,_takeprofit,_comment,_expiration);
   
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

   App().orderrepository.Add(_order);

   _order.NewOrder(
      in_symbol,_ordertype,_mm.GetLotsize(),
      _price == NULL ? 0 : _price.GetPrice(),
      _stoploss == NULL ? 0 : _stoploss.GetPrice(),
      _takeprofit == NULL ? 0 : _takeprofit.GetPrice(),
      _comment,_expiration);

   /*if (_price != NULL) COrderBase::DeleteIf(_price);
   if (_stoploss != NULL) COrderBase::DeleteIf(_stoploss);
   if (_takeprofit != NULL) COrderBase::DeleteIf(_takeprofit);*/
   
   //COrderBase::DeleteIf(_mm);

   return(_order);
}

COrderInterface* COrderManager::NewOrder(COrderInterface* _order, const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagementInterface* _mm,CMoneyManagementInterface*& _mm_ptp[],CStopsCalcInterface* _price,
                                 CStopsCalcInterface* _stoploss,CStopsCalcInterface* _takeprofit,CStopsCalcInterface*& _ptps[],const string _comment="",const datetime _expiration=0)
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

   App().orderrepository.Add(_order);

   _order.NewOrder(
      in_symbol,_ordertype,_mm.GetLotsize(),
      _price == NULL ? 0 : _price.GetPrice(),
      _stoploss == NULL ? 0 : _stoploss.GetPrice(),
      _takeprofit == NULL ? 0 : _takeprofit.GetPrice(),
      _comment,_expiration);
    
    
   for (int i = 0; i < ArraySize(_ptps); i++) {
      CStopsCalcInterface* ptp = _ptps[i];
      CMoneyManagementInterface* mm_ptp = _mm_ptp[i];
      ptp.SetOrderType(_ordertype).SetSymbol(in_symbol).SetEntryPrice(_price != NULL ? _price.GetPrice() : 0);
      ptp.Reset();
      ptp.SetStopLoss(_stoploss);
      mm_ptp.SetSymbol(in_symbol).SetStopLoss(_stoploss).SetOrderType(_ordertype);
      
      _order.AddTakeProfit(ptp.GetPrice(),mm_ptp.GetLotsize());
   
   }

   /*if (_price != NULL) COrderBase::DeleteIf(_price);
   if (_stoploss != NULL) COrderBase::DeleteIf(_stoploss);
   if (_takeprofit != NULL) COrderBase::DeleteIf(_takeprofit);*/
   
   //COrderBase::DeleteIf(_mm);

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

COrderInterface* COrderManager::NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,CMoneyManagementInterface* _mm,CMoneyManagementInterface*& _mm_ptp[],CStopsCalcInterface* _price,
                                 CStopsCalcInterface* _stoploss,CStopsCalcInterface* _takeprofit,CStopsCalcInterface*& _ptps[],const string _comment="",const datetime _expiration=0)
{
   loadsymbol(in_symbol);
   _symbol.RefreshRates();
   COrderInterface* _order = NewOrderObject();
   NewOrder(_order, in_symbol, _ordertype,_mm,_mm_ptp,_price,_stoploss,_takeprofit,_ptps,_comment,_expiration);
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

   App().orderrepository.Add(_order.get());

   _order.get().NewOrder(
      in_symbol,_ordertype,_mm.get().GetLotsize(),
      !_price.isset() ? 0 : _price.get().GetPrice(),
      !_stoploss.isset() ? 0 : _stoploss.get().GetPrice(),
      !_takeprofit.isset() ? 0 : _takeprofit.get().GetPrice(),
      _comment,_expiration);
      
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


#ifdef __MQL4__

bool COrderManager::ExistingOrder(int ticket, COrderBase* orderbase, COrderBase* _order, COrderBase* attachedorder) {
   if (orderbase.ExistingOrder(ticket)) {
      if (CAttachedOrder::IsAttached(orderbase.comment)) {
         if (attachedorder == NULL) attachedorder = global_app().GetDependency(classOrder,classAttachedOrder);
         orderbase.Copy(attachedorder);
         delete _order;
      } else {
         if (_order == NULL) _order = this.NewOrderObject(); 
         orderbase.Copy(_order);   
         delete attachedorder;
      }
      return(true);         
   } else {
      return(false);
   }
};   


COrder* COrderManager::ExistingOrder(int ticket, bool add = true)
{
   COrderBase* _order = this.Prepare(new COrderBase());

   COrder* mainorder = NewOrderObject();
   CAttachedOrder* attachedorder = NewAttachedOrderObject();
   
   if (!ExistingOrder(ticket,_order,mainorder,attachedorder)) {
      delete _order;
      return(NULL);
   }
   delete _order;
   if (CheckPointer(attachedorder) != POINTER_INVALID) {
      attachedorders.Add(attachedorder);
      return(NULL);
   } else if (CheckPointer(mainorder) != POINTER_INVALID) {
      bool found = false;
      COrder* order1;
      for (int i = App().orderrepository.Total()-1; i >= 0; i--) {
         order1 = App().orderrepository.GetByIdx(i);
         if (order1.ticket == mainorder.ticket) {
            found = true;
            break;
         }
      }
      if (!found) {
         App().orderrepository.Add(mainorder);
         return(mainorder);
      } else {
         delete mainorder;
         return(NULL);
      }
   } else {
      return(NULL);
   }
   
}

void COrderManager::AssignAttachedOrders(bool remove_if_not_found = true)
{
   CAttachedOrder* attachedorder;
   CAttachedOrder* attachedorder1;
   COrder* _order;
   int i;
   for (i = attachedorders.Total()-1; i >= 0; i--) {
      attachedorder = (CAttachedOrder*)attachedorders.At(i);        
      int attachedtoticket = (int)str_getvalue(attachedorder.comment,"a="," ");
      string _name = str_getvalue(attachedorder.comment,"n=");
      
      if (App().eventhandler.Info ()) App().eventhandler.Info ("Checking Attached Order "+(string)attachedorder.ticket+" comment: "+attachedorder.comment+" parent:"+(string)attachedtoticket+" name:"+_name,__FUNCTION__);
      
      //Looking for the main order
      if (App().eventhandler.Info ()) App().eventhandler.Info ("Looking for main order ",__FUNCTION__);
      for (int i1 = App().orderrepository.Total()-1; i1 >= 0; i1--) {
         _order = App().orderrepository.GetByIdx(i1);  
         if (App().eventhandler.Info ()) App().eventhandler.Info ("Looking in "+(string)_order.ticket,__FUNCTION__);
         if (_order.ticket == attachedtoticket) {
            // Find out if the order is already attached
            bool found = false;               
            for (int i2 = _order.attachedorders.Total()-1; i2>=0; i2--) {
               attachedorder1 = (CAttachedOrder*)_order.attachedorders.At(i2);
               if (isset(attachedorder1) && isset(attachedorder) && attachedorder1.ticket == attachedorder.ticket) {
                  if (App().eventhandler.Info ()) App().eventhandler.Info ("Already Attached to order "+(string)_order.ticket,__FUNCTION__);
                  found = true;
                  break;
               }
            }
            
            // If not found, adding
            if (!found) {
               if (App().eventhandler.Info ()) App().eventhandler.Info ("Not Found, Attaching",__FUNCTION__);
               attachedorder.name = _name;
               _order.attachedorders.Add(attachedorder);
            }
            
            // Remove from the unassigned attached order               
            attachedorders.Detach(i);
            break;
         }          
      }
   }
   
   if (remove_if_not_found) {
      
      for (i = attachedorders.Total()-1; i >= 0; i--) {
         attachedorder = (CAttachedOrder*)attachedorders.At(i);
         if (App().eventhandler.Info ()) App().eventhandler.Info ("Remove unassigned attached order "+(string)attachedorder.ticket,__FUNCTION__);
         attachedorder.Close();
         attachedorders.Delete(i);
      }
   }
   
}

int COrderManager::LoadOpenOrders(string __symbol, int __magic)
{
   int cnt = 0;
   for (int i = OriginalOrdersTotal()-1; i >= 0; i--) {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {

         if (OrderSymbol() != __symbol) continue;
         if (OrderMagicNumber() != __magic) continue;
         if (App().orderrepository.GetIdxByTicket(OrderTicket()) >= 0) continue;

         COrder* exord;
         exord = ExistingOrder(OrderTicket());
         if (exord != NULL) {
            Print("new order found: ticket "+(string)exord.GetTicket()+" type: "+EnumToString((ENUM_CLASS_NAMES)exord.Type()));
            cnt++;
         } else {
            //Print("Order Adding Failed");
         }
      }
   }
   AssignAttachedOrders();
   return cnt;
}

#endif

#endif