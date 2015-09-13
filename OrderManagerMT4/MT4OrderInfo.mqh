//+------------------------------------------------------------------+
//|                                                    OrderInfo.mqh |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//|                                              Revision 2010.08.01 |
//+------------------------------------------------------------------+
/*
#include <Object.mqh>
#include "..\SymbolInfoMT4\SymbolInfo.mqh"
*/

bool orderinfo_log = false;
ulong COrderInfo_SelectedTicket = -1;

class COrderInfo : private CObject
  {
protected:
   // no change
   int m_ticket;
   int  m_magic;
   string m_symbol;
   string m_comment;
   bool no_comment;
   
   // change after state change
   datetime m_opentime;
   double m_openprice;
   double m_lots;
   double m_closeprice;
   
   // change after orderselect
   datetime m_closetime;
   int m_ordertype;

   ENUM_ORDER_STATE m_state;
   ENUM_ORDER_STATE m_laststate;
   
   double m_stoploss;
   double m_takeprofit;
   datetime m_expiration;

   int m_pool;

public:
                     COrderInfo();
   int             Ticket()                        { return(m_ticket); }

   string TypeDescription()            ;
   //datetime TimeExpiration()           ;
   
   // No Change:
   ulong GetTicket() { return(m_ticket); }
   int GetMagicNumber() { return(m_magic!=-1 ? m_magic : (CheckTicket()?m_magic=OrderMagicNumber():m_magic)); }
   string GetSymbol() { return(m_symbol!="" ? m_symbol : (CheckTicket()?m_symbol=OrderSymbol():m_symbol)); }
   string GetComment() { if (m_comment!="" || no_comment) return(m_comment); else { if (CheckTicket()) m_comment=OrderComment(); no_comment=(m_comment==""); return(m_comment); } }
   
   // Change After State Change:
   ENUM_ORDER_TYPE GetType() { return((ENUM_ORDER_TYPE)(m_ordertype!=-1 ? m_ordertype : (CheckTicket()?(m_ordertype=OrderType()):m_ordertype))); }
   datetime GetOpenTime() { return(m_opentime!=-1 ? m_opentime : (CheckTicket()?m_opentime=OrderOpenTime():m_opentime)); }
   double GetOpenPrice() { return(m_openprice!=0 ? m_openprice : (CheckTicket()?m_openprice=OrderOpenPrice():m_openprice)); }
   double GetLots() { return(m_lots!=0 ? m_lots : (CheckTicket()?m_lots=OrderLots():m_lots)); }
   double GetClosePrice() { return(m_closeprice!=0 ? m_closeprice : (CheckTicket()?m_closeprice=OrderClosePrice():m_closeprice)); }
   datetime GetCloseTime() { return(m_closetime!=-1 ? m_closetime : (CheckTicket()?m_closetime=OrderCloseTime():m_closetime)); }

   // Change after select:   
   ENUM_ORDER_STATE State() ;
   double GetStopLoss() { return(m_stoploss!=EMPTY_VALUE ? m_stoploss : (CheckTicket()?m_stoploss=OrderStopLoss():m_stoploss)); }
   double GetTakeProfit() { return(m_takeprofit!=EMPTY_VALUE ? m_takeprofit : (CheckTicket()?m_takeprofit=OrderTakeProfit():m_takeprofit)); }
   datetime GetExpiration() { return(m_expiration!=-1 ? m_expiration : (CheckTicket()?m_expiration=OrderExpiration():m_expiration)); }

   //--- info methods
   static string FormatType(string& str,const uint type);
   static string FormatType(const uint type);

   //--- method for select order

   bool Select(ulong ticket, int pool = MODE_TRADES);
   bool SelectByIndex(int index, int pool = MODE_TRADES);

   //--- addition methods

   bool CheckTicket()
   {
      if (COrderInfo_SelectedTicket != m_ticket) return(Select(m_ticket,m_pool));
      else return(true);
   }
   
};

COrderInfo::COrderInfo()
{   
   // no change
   m_ticket = -1;
   m_magic = -1;
   m_symbol = "";
   m_comment = "";
   no_comment = false;
   
   // change after state change
   m_opentime = -1;
   m_openprice = 0;
   m_lots = 0;
   
   // change after orderselect
   m_ordertype = -1;
   m_closetime = -1;
   m_closeprice = 0;

   m_state = 0;
   m_laststate = 0;
   
   m_stoploss = EMPTY_VALUE;
   m_takeprofit = EMPTY_VALUE;
   m_expiration = -1;

   m_pool = MODE_TRADES;
}
  
ENUM_ORDER_STATE COrderInfo::State()
{
   if (!CheckTicket()) return(m_state=ORDER_STATE_UNKNOWN);
   if (m_state != 0) return(m_state);
      
   int type;
   if (GetCloseTime() == 0) {
      type = GetType();      
      if (type == ORDER_TYPE_BUY || type == ORDER_TYPE_SELL) return(m_state=ORDER_STATE_FILLED);
      else return(m_state=ORDER_STATE_PLACED);
   } else {
      type = GetType();
      if (type == ORDER_TYPE_BUY || type == ORDER_TYPE_SELL) return(m_state=ORDER_STATE_CLOSED);
      else return(m_state=ORDER_STATE_DELETED);
   }
}
  
string COrderInfo::TypeDescription()
{
   CheckTicket();
   string str;
   return(FormatType(str,GetType()));
}

static string COrderInfo::FormatType(string& str,const uint type)
{
   str="";
   switch(type)
   {
      case ORDER_TYPE_BUY            : str="buy";             break;
      case ORDER_TYPE_SELL           : str="sell";            break;
      case ORDER_TYPE_BUY_LIMIT      : str="buy limit";       break;
      case ORDER_TYPE_SELL_LIMIT     : str="sell limit";      break;
      case ORDER_TYPE_BUY_STOP       : str="buy stop";        break;
      case ORDER_TYPE_SELL_STOP      : str="sell stop";       break;

      default:
         str="unknown order type "+(string)type;
         break;
   }
   return(str);
}

static string COrderInfo::FormatType(const uint type)
{
   string str="";
   COrderInfo::FormatType(str,type);
   return(str);
}

bool COrderInfo::Select(ulong ticket, int pool = MODE_TRADES)
{   
   if (ticket != m_ticket) {
      m_ticket = ticket;
      m_magic = -1;
      m_symbol = "";
      m_comment = "";
      no_comment = false;
      
      m_opentime = -1;
      m_openprice = 0;
      m_lots = 0; 
   }

   if(OrderSelect(ticket,SELECT_BY_TICKET,pool))
   {
      m_pool = pool;
      COrderInfo_SelectedTicket = m_ticket;
      if (orderinfo_log) Print("selected by ticket: ",COrderInfo_SelectedTicket);
            
      m_ordertype = -1;
      m_closetime = -1;
      m_closeprice = 0;
   
      m_openprice = 0;
      m_stoploss = EMPTY_VALUE;
      m_takeprofit = EMPTY_VALUE;
      m_expiration = -1;
      
      m_laststate = m_state;      
      m_state = 0;      
      State();
      
      if (m_state != m_laststate) {
         m_opentime = -1;
         m_lots = 0;
      }            
      
      return(true);
   }
   
   m_ticket=-1;
   COrderInfo_SelectedTicket = m_ticket;
   if (orderinfo_log) Print("selected by ticket: ",COrderInfo_SelectedTicket);

   return(false);
}

bool COrderInfo::SelectByIndex(int index, int pool = MODE_TRADES)
{
   if(OrderSelect(index,SELECT_BY_POS,pool))
   {
      m_pool = pool;
      
      int ticket = OrderTicket();
      if (ticket != m_ticket) {
         m_ticket=ticket;
         m_magic = -1;
         m_symbol = "";
         m_comment = "";
         no_comment = false;
         
         m_laststate = 0;
         m_state = 0;
         State();
         
         m_opentime = -1;
         m_openprice = 0;
         m_lots = 0;
             
      } else {
         m_laststate = m_state;
         m_state = 0;
         State();
      
         if (m_state != m_laststate) {
            m_opentime = -1;
            m_lots = 0;
         }
      }
            
      COrderInfo_SelectedTicket = m_ticket;
      if (orderinfo_log) Print("selected by pos: ",COrderInfo_SelectedTicket);
      
      m_ordertype = -1;
      m_closetime = -1;
      m_closeprice = 0;
   
      m_openprice = 0;
      m_stoploss = EMPTY_VALUE;
      m_takeprofit = EMPTY_VALUE;
      m_expiration = -1;
      
      return(true);
   }
   
   m_ticket=-1;
   COrderInfo_SelectedTicket = m_ticket;
   if (orderinfo_log) Print("selected by pos: ",COrderInfo_SelectedTicket);

   return(false);
}