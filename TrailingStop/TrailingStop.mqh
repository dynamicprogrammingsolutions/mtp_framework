//+------------------------------------------------------------------+
//|                                                      traling.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include "..\Loader.mqh"

class CTrailingStop : CAppObject
{
   public:
      
   double lockin;
   double trailingstop;
   double activate;
   double step;
   double stoptrailing;
   double lockinprofit;
   bool trailingstop_round;
   
   TraitAppAccess
   TraitLoadSymbolFunction

   COrderManager* om;
   
   CTrailingStop()
   {
      lockin = 0;
      trailingstop = 0;
      activate = 0;
      step = 1;
      stoptrailing = 0;
      lockinprofit = 0;
      trailingstop_round = false;
   }
   
   virtual void Initalize()
   {
      om = this.App().GetService(srvOrderManager); 
   }
   
   void Fract()
   {
      lockin = lockin*10;
      trailingstop = trailingstop*10;
      activate = activate*10;
      step = step*10;
      stoptrailing = stoptrailing*10;
      lockinprofit = lockinprofit*10;
   }
   
   double Calc(double orderprofit, const double ordersl)
   {
      double ret = ordersl;
   
      double _sl = ordersl;
      double newsl = _sl;
   
      if ((lockin > 0) && (orderprofit >= lockin) && (newsl > -lockinprofit)) {
         newsl = -lockinprofit;
      }
      if (trailingstop_round && trailingstop > 0) {
         double trailingstart = activate-trailingstop;
         if (orderprofit >= trailingstart) {
         	double profitfromstart = orderprofit-trailingstart;
         	orderprofit = trailingstart+(MathFloor(profitfromstart/step)*step);
         }	
      }
      if ((trailingstop > 0) && (orderprofit >= activate) && ((newsl == EMPTY_VALUE) || (newsl >= -orderprofit + trailingstop + step))
      && ((stoptrailing <= 0) || (orderprofit <= stoptrailing))) {
         newsl = -orderprofit + trailingstop;
      }
      if (newsl != _sl)
      {
         ret = newsl;
      }
      return(ret);
   }
   
   double CalcTP(double orderprofit, const double ordertp)
   {
      double ret = ordertp;
   
      double _tp = ordertp;
      double newtp = _tp;
   
      if ((lockin != 0) && (orderprofit <= lockin) && (newtp > lockinprofit)) {
         newtp = lockinprofit;
      }
      if (trailingstop_round && trailingstop > 0) {
         double trailingstart = activate+trailingstop;
         if (orderprofit <= trailingstart) {
         	double profitfromstart = trailingstart-orderprofit;
         	orderprofit = trailingstart-(MathFloor(profitfromstart/step)*step);
         }
      }
      if ((trailingstop != 0) && (orderprofit <= activate) && ((newtp == EMPTY_VALUE) || (newtp >= orderprofit + trailingstop - step))
      && ((stoptrailing == 0) || (orderprofit >= stoptrailing))) {
         newtp = orderprofit + trailingstop;
      }
      if (newtp != _tp)
      {
         ret = newtp;
      }
      return(ret);
   }
   
   bool OnOrder(ulong ticket)
   {
      COrder* _order = om.GetOrderByTicket(ticket);
      if (_order == NULL) return(false);
      return(OnOrder(_order));
   }
   
   bool OnOrder(COrder* in_order)
   {      
      if (in_order == NULL) return(false);
      //in_order.Update();
      if (in_order.State() != ORDER_STATE_FILLED) return(false);
      bool ret = false;
      loadsymbol(in_order.symbol);
      int _sl = in_order.GetStopLossTicks();
      //Print("TS sl:",_sl);
      int newsl = _sl;
      int orderprofit = in_order.GetProfitTicks();   
      newsl = (int)Calc(orderprofit, _sl);      
      if (newsl != _sl)
      {
         in_order.SetStopLoss(getstoplossprice(in_order.symbol,in_order.GetType(),newsl,in_order.Price()));
         in_order.Modify();
         //Print("modified new sl:",in_order.sl);
         ret = true;
      }
      return(ret);
   }
   
   bool TrailingTPOnOrder(COrder* in_order)
   {      
      if (in_order == NULL) return(false);
      //in_order.Update();
      if (in_order.State() != ORDER_STATE_FILLED) return(false);
      bool ret = false;
      loadsymbol(in_order.symbol);
      int _tp = in_order.GetTakeProfitTicks();
      //Print("TS sl:",_sl);
      int newtp = _tp;
      int orderprofit = in_order.GetProfitTicks();   
      newtp = (int)CalcTP(orderprofit, _tp);      
      if (newtp != _tp)
      {
         in_order.SetTakeProfit(gettakeprofitprice(in_order.symbol,in_order.GetType(),newtp,in_order.Price()));
         in_order.Modify();
         //Print("modified new sl:",in_order.sl);
         ret = true;
      }
      return(ret);
   }
   
   bool OnOrderArrayAvgprice(COrderArray* in_orderarr,ENUM_ORDERSELECT select = ORDERSELECT_ANY)
   {      
      bool ret = false;
      
      
      
      if (select == ORDERSELECT_LONG) select = ORDERSELECT_BUY;
      if (select == ORDERSELECT_SHORT) select = ORDERSELECT_SELL;      
      if (select == ORDERSELECT_ANY || select == ORDERSELECT_MARKET) {
         int cntbuy = in_orderarr.CntOrders(ORDERSELECT_BUY,STATESELECT_FILLED);
         int cntsell = in_orderarr.CntOrders(ORDERSELECT_SELL,STATESELECT_FILLED);
         if (cntbuy == 0 && cntsell > 0) select = ORDERSELECT_SELL;
         if (cntbuy > 0 && cntsell == 0) select = ORDERSELECT_BUY;
      }
      if (select != ORDERSELECT_BUY && select != ORDERSELECT_SELL) return false;
      
      double avgprice = in_orderarr.AvgPrice(select,STATESELECT_FILLED);
      if (avgprice == 0) return false;
      
      int _sl = 0;
      int i;
      COrder* _order;
      if (select == ORDERSELECT_BUY) {
         double highestsl = 0;
         for (i = 0; i < in_orderarr.Total(); i++) {
            _order = in_orderarr.At(i);
            if (!ordertype_select(select,_order.GetType())) continue;
            if (_order.GetStopLoss() != 0) highestsl = MathMaxNoZero(highestsl,_order.GetStopLoss());
         }
         if (highestsl != 0)
            _sl = _symbol.InTicks(avgprice-highestsl);
      }

      if (select == ORDERSELECT_SELL) {
         double lowestsl = 0;
         for (i = 0; i < in_orderarr.Total(); i++) {
            _order = in_orderarr.At(i);
            if (!ordertype_select(select,_order.GetType())) continue;
            if (_order.GetStopLoss() != 0) lowestsl = MathMinNoZero(lowestsl,_order.GetStopLoss());
         }
         if (lowestsl != 0)
            _sl = _symbol.InTicks(lowestsl-avgprice);
      }
      
      //int _sl = in_order.GetStopLossTicks();
      int newsl = _sl;
      int orderprofit = 0;
      if (select == ORDERSELECT_BUY) {
         orderprofit = _symbol.InTicks(_symbol.Bid()-avgprice);
      }
      if (select == ORDERSELECT_SELL) {
         orderprofit = _symbol.InTicks(avgprice-_symbol.Ask());
      }
      newsl = (int)Calc(orderprofit, _sl);
      
      //Print("avgprice: "+avgprice+" orderprofit:"+orderprofit+" old sl: "+_sl+" newsl:"+newsl+" highestsl:"+lowestsl+" lowestsl:"+lowestsl+" ask:"+_symbol.Ask()+" bid:"+_symbol.Bid());
            
      if (newsl != _sl)
      {
         double newsl_price = 0;
         if (select == ORDERSELECT_BUY) {
            newsl_price = avgprice-newsl*_symbol.TickSize();
         }
         if (select == ORDERSELECT_SELL) {
            newsl_price = avgprice+newsl*_symbol.TickSize();
         }
      
         //Print("newsl: "+newsl+" newsl price: "+newsl_price+" avgprice"+avgprice);
      
         for (i = 0; i < in_orderarr.Total(); i++) {
            _order = in_orderarr.At(i);
            if (!ordertype_select(select,_order.GetType())) continue;
            _order.SetStopLoss(newsl_price);
            _order.Modify();
         }
         ret = true;
      }
      return(ret);
   }
   
   bool OnAll(ENUM_ORDERSELECT type = ORDERSELECT_ANY, ENUM_STATESELECT state = STATESELECT_ANY)
   {
      if (trailingstop == 0 && lockin == 0) return(false);
      
      //if (event.Debug ()) event.Debug ("Trailing Stop",__FUNCTION__);
      bool ret = false;
      for (int i=0; i < om.OrdersTotal(); i++)
      {
         COrder* _order = om.GetOrderByIdx(i);
         if (!ordertype_select(type,_order.GetType())) continue;
         if (!state_select(state,_order.State())) continue;
         OnOrder(_order);
      }
      return(ret);
   }
   
   bool TrailingTPOnAll(ENUM_ORDERSELECT type = ORDERSELECT_ANY, ENUM_STATESELECT state = STATESELECT_ANY)
   {
      if (trailingstop == 0 && lockin == 0) return(false);
      
      //if (event.Debug ()) event.Debug ("Trailing Stop",__FUNCTION__);
      bool ret = false;
      for (int i=0; i < om.OrdersTotal(); i++)
      {
         COrder* _order = om.GetOrderByIdx(i);
         if (!ordertype_select(type,_order.GetType())) continue;
         if (!state_select(state,_order.State())) continue;
         TrailingTPOnOrder(_order);
      }
      return(ret);
   }
   
   bool OnAllByIndicator(double buysl, double sellsl)
   {
      bool ret = false;
      for (int i=0; i < om.OrdersTotal(); i++)
      {
         COrder* _order = om.GetOrderByIdx(i);
         _order.Select();
         if (_order.State() == ORDER_STATE_FILLED) {
            loadsymbol(_order.symbol);
            bool change = false;
            double newsl = 0;
            if (_order.GetType() == OP_BUY) {
               newsl = buysl;
               change = (_order.GetStopLoss() == 0 || _order.GetStopLoss() < newsl);
            } else {
               newsl = sellsl;
               change = (_order.GetStopLoss() == 0 || _order.GetStopLoss() > newsl);               
            }
            if (change) {               
               _order.SetStopLoss(newsl);
               _order.SetTakeProfit(_order.GetTakeProfit());
               _order.Modify();
               ret = true;
            }
         }
      }
      return(ret);
   }
   
   bool OnOrderByIndicator(COrder* _order, double buysl, double sellsl)
   {
      bool ret = false;
      if (_order.State() == ORDER_STATE_FILLED) {
         loadsymbol(_order.symbol);
         bool change = false;
         double newsl = 0;
         if (_order.GetType() == OP_BUY) {
            newsl = buysl;
            change = (_order.GetStopLoss() == 0 || _order.GetStopLoss() < newsl);
         } else {
            newsl = sellsl;
            change = (_order.GetStopLoss() == 0 || _order.GetStopLoss() > newsl);               
         }
         if (change) {               
            _order.SetStopLoss(newsl);
            _order.SetTakeProfit(_order.GetTakeProfit());
            _order.Modify();
            ret = true;
         }
      }      
      return(ret);
   }
};