//
#include "..\Loader.mqh"

#define ORDER_INFO_V_H
ulong COrderInfo_SelectedTicket = -1;

class COrderInfoV : public COrderInfoBase
  {
protected:
   ulong             m_ticket;
   ENUM_ORDER_TYPE   m_type;
   ENUM_ORDER_STATE  m_state;
   datetime          m_expiration;
   double            m_volume_curr;
   double            m_stop_loss;
   double            m_take_profit;
   
   ENUM_ORDER_STATE  m_laststate;
   
   long m_magic;
   string m_symbol;
   string m_comment;
   bool no_comment;
   
   double m_openprice;
   double m_currentprice;
   
   datetime m_timedone;
   datetime m_timesetup;
   ENUM_ORDER_TYPE_TIME m_typetime;

public:

                     COrderInfoV();
   ulong             Ticket()                        { return(m_ticket); }
   //--- fast access methods to the integer order propertyes
   datetime          TimeSetup()                    ;
   ENUM_ORDER_TYPE   OrderType()                    ;
   string            TypeDescription()              ;
   ENUM_ORDER_STATE  State()                        ;
   string            StateDescription()             ;
   datetime          TimeExpiration()               ;
   datetime          TimeDone()                     ;
   ENUM_ORDER_TYPE_FILLING TypeFilling()            ;
   string                  TypeFillingDescription() ;
   ENUM_ORDER_TYPE_TIME    TypeTime()               ;
   string                  TypeTimeDescription()    ;
   long              Magic()                        ;
   long              PositionId()                   ;
   //--- fast access methods to the double order propertyes
   double            VolumeInitial()                ;
   double            VolumeCurrent()                ;
   double            PriceOpen()                    ;
   double            StopLoss()                     ;
   double            TakeProfit()                   ;
   double            PriceCurrent()                 ;
   double            PriceStopLimit()               ;
   //--- fast access methods to the string order propertyes
   string            Symbol()                       ;
   string            Comment()                      ;
   //--- access methods to the API MQL5 functions
   bool              InfoInteger(ENUM_ORDER_PROPERTY_INTEGER prop_id,long& var);
   bool              InfoDouble(ENUM_ORDER_PROPERTY_DOUBLE prop_id,double& var);
   bool              InfoString(ENUM_ORDER_PROPERTY_STRING prop_id,string& var);
   //--- info methods
   string            FormatType(string& str,const uint type)                    const;
   string            FormatStatus(string& str,const uint status)                const;
   string            FormatTypeFilling(string& str,const uint type)             const;
   string            FormatTypeTime(string& str,const uint type)                const;
   string            FormatOrder(string& str)                                   ;
   string            FormatPrice(string& str,const double price_order,const double price_trigger,const uint __digits) const;
   //--- method for select order
   virtual bool              Select(ulong ticket);
   //bool              Ticket(ulong ticket) { return(Select(ticket)); }
   bool              SelectByIndex(int index);
   //--- addition methods
   void              StoreState();
   bool              CheckState();
   bool CheckTicket()
   {
      if (COrderInfo_SelectedTicket != m_ticket) return(Select(m_ticket));
      else return true;
   }
   
  };
//+------------------------------------------------------------------+
//| Constructor.                                                     |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
COrderInfoV::COrderInfoV()
  {
   m_ticket     =ULONG_MAX;
   m_type       =WRONG_VALUE;
   m_state      =WRONG_VALUE;
   m_expiration =0;
   m_volume_curr=0.0;
   m_stop_loss  =0.0;
   m_take_profit=0.0;
   
   m_magic = -1;
   m_symbol = "";
   m_comment = "";
   no_comment = false;
   
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TIME_SETUP".                       |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TIME_SETUP".                   |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
datetime COrderInfoV::TimeSetup()
{
   return(m_timesetup!=0 ? m_timesetup : (CheckTicket()?m_timesetup=(datetime)OrderGetInteger(ORDER_TIME_SETUP):m_timesetup)); 
}
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TYPE".                             |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TYPE".                         |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE COrderInfoV::OrderType()
  {
   CheckTicket();
   return((ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TYPE" as string.                   |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TYPE" as string.               |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string COrderInfoV::TypeDescription()
  {
   CheckTicket();
   string str;
//---
   return(FormatType(str,OrderType()));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_STATE".                            |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_STATE".                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
ENUM_ORDER_STATE COrderInfoV::State()
{
   CheckTicket();
   if (m_state != 0) return(m_state);
   return((ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE));
}
//+------------------------------------------------------------------+
//| Get the property value "ORDER_STATE" as string.                  |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_STATE" as string.              |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string COrderInfoV::StateDescription()
  {
   CheckTicket();
   string str;
//---
   return(FormatStatus(str,State()));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TIME_EXPIRATION".                  |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TIME_EXPIRATION".              |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
datetime COrderInfoV::TimeExpiration()
{
   return(m_expiration!=0 ? m_expiration : (CheckTicket()?m_expiration=(datetime)OrderGetInteger(ORDER_TIME_EXPIRATION):m_expiration)); 
}
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TIME_DONE".                        |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TIME_DONE".                    |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
datetime COrderInfoV::TimeDone()
{
   return(m_timedone!=0 ? m_timedone : (CheckTicket()?m_timedone=(datetime)OrderGetInteger(ORDER_TIME_DONE):m_timedone)); 
}
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TYPE_FILLING".                     |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TYPE_FILLING".                 |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING COrderInfoV::TypeFilling()
  {
   CheckTicket();
   return((ENUM_ORDER_TYPE_FILLING)OrderGetInteger(ORDER_TYPE_FILLING));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TYPE_FILLING" as string.           |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TYPE_FILLING" as string.       |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string COrderInfoV::TypeFillingDescription()
  {
   CheckTicket();
   string str;
//---
   return(FormatTypeFilling(str,TypeFilling()));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TYPE_TIME".                        |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TYPE_TIME".                    |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_TIME COrderInfoV::TypeTime()
{
   return(m_typetime!=-1 ? m_typetime : (CheckTicket()?m_typetime=(ENUM_ORDER_TYPE_TIME)OrderGetInteger(ORDER_TYPE_TIME):m_typetime)); 
}
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TYPE_TIME" as string.              |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TYPE_TIME" as string.          |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string COrderInfoV::TypeTimeDescription()
  {
   CheckTicket();
   string str;
//---
   return(FormatTypeTime(str,TypeFilling()));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_MAGIC".                            |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_MAGIC".                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
long COrderInfoV::Magic()
{
   return(m_magic!=-1 ? m_magic : (CheckTicket()?m_magic=OrderGetInteger(ORDER_MAGIC):m_magic)); 
}
//+------------------------------------------------------------------+
//| Get the property value "ORDER_POSITION_ID".                      |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_POSITION_ID".                  |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
long COrderInfoV::PositionId()
  {
   return(HistoryOrderGetInteger(m_ticket,ORDER_POSITION_ID));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_VOLUME_INITIAL".                   |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_VOLUME_INITIAL".               |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double COrderInfoV::VolumeInitial()
  {
   CheckTicket();
   return(OrderGetDouble(ORDER_VOLUME_INITIAL));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_VOLUME_CURRENT".                   |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_VOLUME_CURRENT".               |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double COrderInfoV::VolumeCurrent()
  {
   CheckTicket();
   return(OrderGetDouble(ORDER_VOLUME_CURRENT));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_PRICE_OPEN".                       |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_PRICE_OPEN".                   |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double COrderInfoV::PriceOpen()
{
   return(m_openprice!=0 ? m_openprice : (CheckTicket()?m_openprice=OrderGetDouble(ORDER_PRICE_OPEN):m_openprice));
}
//+------------------------------------------------------------------+
//| Get the property value "ORDER_SL".                               |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_SL".                           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double COrderInfoV::StopLoss()
  {
   CheckTicket();
   return(OrderGetDouble(ORDER_SL));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TP".                               |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TP".                           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double COrderInfoV::TakeProfit()
  {
   CheckTicket();
   return(OrderGetDouble(ORDER_TP));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_PRICE_CURRENT".                    |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_PRICE_CURRENT".                |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double COrderInfoV::PriceCurrent()
{
   return(m_currentprice!=0 ? m_currentprice : (CheckTicket()?m_currentprice=OrderGetDouble(ORDER_PRICE_CURRENT):m_currentprice));  
}
//+------------------------------------------------------------------+
//| Get the property value "ORDER_PRICE_STOPLIMIT".                  |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_PRICE_STOPLIMIT".              |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double COrderInfoV::PriceStopLimit()
  {
   CheckTicket();
   return(OrderGetDouble(ORDER_PRICE_STOPLIMIT));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_SYMBOL".                           |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_SYMBOL".                       |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string COrderInfoV::Symbol()
{
   return(m_symbol!="" ? m_symbol : (CheckTicket()?m_symbol=OrderGetString(ORDER_SYMBOL):m_symbol));
}
//+------------------------------------------------------------------+
//| Get the property value "ORDER_COMMENT".                          |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_COMMENT".                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string COrderInfoV::Comment()
{
   if (m_comment!="" || no_comment) return(m_comment); else { if (CheckTicket()) m_comment=OrderGetString(ORDER_COMMENT); no_comment=(m_comment==""); return(m_comment); }
}
//+------------------------------------------------------------------+
//| Access functions OrderGetInteger(...).                           |
//| INPUT:  prop_id -identifier integer properties,                  |
//|         var     -reference to a variable to value.               |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool COrderInfoV::InfoInteger(ENUM_ORDER_PROPERTY_INTEGER prop_id,long& var)
  {
   CheckTicket();
   return(OrderGetInteger(prop_id,var));
  }
//+------------------------------------------------------------------+
//| Access functions OrderGetDouble(...).                            |
//| INPUT:  prop_id -identifier double properties,                   |
//|         var     -reference to a variable to value.               |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool COrderInfoV::InfoDouble(ENUM_ORDER_PROPERTY_DOUBLE prop_id,double& var)
  {
   CheckTicket();
   return(OrderGetDouble(prop_id,var));
  }
//+------------------------------------------------------------------+
//| Access functions OrderGetString(...).                            |
//| INPUT:  prop_id -identifier string properties,                   |
//|         var     -reference to a variable to value.               |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool COrderInfoV::InfoString(ENUM_ORDER_PROPERTY_STRING prop_id,string& var)
  {
   CheckTicket();
   return(OrderGetString(prop_id,var));
  }
//+------------------------------------------------------------------+
//| Converts the order type to text.                                 |
//| INPUT:  str  - receiving string,                                 |
//|         type - order type.                                       |
//| OUTPUT: formatted string.                                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string COrderInfoV::FormatType(string& str,const uint type) const
  {
//--- clean
   str="";
//--- see the type
   switch(type)
     {
      case ORDER_TYPE_BUY            : str="buy";             break;
      case ORDER_TYPE_SELL           : str="sell";            break;
      case ORDER_TYPE_BUY_LIMIT      : str="buy limit";       break;
      case ORDER_TYPE_SELL_LIMIT     : str="sell limit";      break;
      case ORDER_TYPE_BUY_STOP       : str="buy stop";        break;
      case ORDER_TYPE_SELL_STOP      : str="sell stop";       break;
      case ORDER_TYPE_BUY_STOP_LIMIT : str="buy stop limit";  break;
      case ORDER_TYPE_SELL_STOP_LIMIT: str="sell stop limit"; break;

      default:
         str="unknown order type "+(string)type;
         break;
     }
//--- return the result
   return(str);
  }
//+------------------------------------------------------------------+
//| Converts the order status to text.                               |
//| INPUT:  str    - receiving string,                               |
//|         status - order status.                                   |
//| OUTPUT: formatted string.                                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string COrderInfoV::FormatStatus(string& str,const uint status) const
  {
//--- clean
   str="";
//--- see the type
   switch(status)
     {
      case ORDER_STATE_STARTED : str="started";  break;
      case ORDER_STATE_PLACED  : str="placed";   break;
      case ORDER_STATE_CANCELED: str="canceled"; break;
      case ORDER_STATE_PARTIAL : str="partial";  break;
      case ORDER_STATE_FILLED  : str="filled";   break;
      case ORDER_STATE_REJECTED: str="rejected"; break;
      case ORDER_STATE_EXPIRED : str="expired";  break;

      default:
         str="unknown order status "+(string)status;
         break;
     }
//--- return the result
   return(str);
  }
//+------------------------------------------------------------------+
//| Converts the order filling type to text.                         |
//| INPUT:  str  - receiving string,                                 |
//|         type - order filling type.                               |
//| OUTPUT: formatted string.                                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string COrderInfoV::FormatTypeFilling(string& str,const uint type) const
  {
//--- clean
   str="";
//--- see the type
   switch(type)
     {
      case ORDER_FILLING_RETURN: str="return remainder"; break;
      case ORDER_FILLING_IOC   : str="cancel remainder"; break;
      case ORDER_FILLING_FOK   : str="all or none";      break;

      default:
         str="unknown type filling "+(string)type;
         break;
     }
//--- return the result
   return(str);
  }
//+------------------------------------------------------------------+
//| Converts the type of order by expiration to text.                |
//| INPUT:  str  - receiving string,                                 |
//|         type - type of order by expiration.                      |
//| OUTPUT: formatted string.                                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string COrderInfoV::FormatTypeTime(string& str,const uint type) const
  {
//--- clean
   str="";
//--- see the type
   switch(type)
     {
      case ORDER_TIME_GTC          : str="gtc";           break;
      case ORDER_TIME_DAY          : str="day";           break;
      case ORDER_TIME_SPECIFIED    : str="specified";     break;
      case ORDER_TIME_SPECIFIED_DAY: str="specified day"; break;

      default:
         str="unknown type time "+(string)type;
         break;
     }
//--- return the result
   return(str);
  }
//+------------------------------------------------------------------+
//| Converts the order parameters to text.                           |
//| INPUT:  str      - receiving string,                             |
//|         position - pointer at the class instance.                |
//| OUTPUT: formatted string.                                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string COrderInfoV::FormatOrder(string& str)
  {
   CheckTicket();
   string      type,price;
   CSymbolInfo __symbol;
//--- set up
   __symbol.Name(Symbol());
   int __digits=__symbol.Digits();
//--- form the order description
   str = StringFormat("#%I64u %s %s %s",
                Ticket(),
                FormatType(type,OrderType()),
                DoubleToString(VolumeInitial(),2),
                Symbol());
//--- receive the price of the order
   FormatPrice(price,PriceOpen(),PriceStopLimit(),__digits);
//--- if there is price, write it
   if(price!="")
     {
      str+=" at ";
      str+=price;
     }
//--- return the result
   return(str);
  }
//+------------------------------------------------------------------+
//| Converts the order prices to text.                               |
//| INPUT:  str           - receiving string,                        |
//|         price_order   - order price,                             |
//|         price_trigger - the order trigger price.                 |
//| OUTPUT: formatted string.                                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string COrderInfoV::FormatPrice(string& str,const double price_order,const double price_trigger,const uint __digits) const
  {
   string price,trigger;
//--- clean
   str="";
//--- Is there its trigger price?
   if(price_trigger)
     {
      price  =DoubleToString(price_order,__digits);
      trigger=DoubleToString(price_trigger,__digits);
      str    =StringFormat("%s (%s)",price,trigger);
     }
   else str=DoubleToString(price_order,__digits);
//--- return the result
   return(str);
  }
//+------------------------------------------------------------------+
//| Selecting a order to access.                                     |
//| INPUT:  ticket -order ticket.                                    |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool COrderInfoV::Select(ulong ticket)
  {
  
   if (ticket != m_ticket) {
      m_ticket = ticket;
      m_magic = -1;
      m_symbol = "";
      m_comment = "";
      no_comment = false;
   }
  
   //if (COrderInfo_SelectedTicket == ticket) return(true);
   if(OrderSelect(ticket))
   {
      m_ticket=ticket;
      COrderInfo_SelectedTicket = m_ticket;

      m_openprice = 0;
      m_currentprice = 0;
      
      m_laststate = m_state;
      m_state = 0;
      State();
      
      if (m_state != m_laststate) {
         //m_opentime = -1;
         //m_lots = 0;
         
         m_expiration = 0;
         m_timedone = 0;
         m_timesetup = 0;         
         m_typetime = -1;
         
      }
      
      return(true);
   }
   
   m_ticket=ULONG_MAX;
   COrderInfo_SelectedTicket = m_ticket;
   
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Select a order on the index.                                     |
//| INPUT:  index - order index.                                     |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool COrderInfoV::SelectByIndex(int index)
  {
   ulong ticket=OrderGetTicket(index);
   if(ticket==0) return(false);
//---
   return(Select(ticket));
  }
//+------------------------------------------------------------------+
//| Stored order's current state.                                    |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void COrderInfoV::StoreState()
  {
   m_type       =OrderType();
   m_state      =State();
   m_expiration =TimeExpiration();
   m_volume_curr=VolumeCurrent();
   m_stop_loss  =StopLoss();
   m_take_profit=TakeProfit();
  }
//+------------------------------------------------------------------+
//| Check order change.                                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true - if order changed.                                 |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool COrderInfoV::CheckState()
  {
   if(m_type==OrderType() && m_state==State() &&
      m_expiration ==TimeExpiration() &&
      m_volume_curr==VolumeCurrent() &&
      m_stop_loss==StopLoss() &&
      m_take_profit==TakeProfit())
      return(false);
   else
      return(true);
  }
//+------------------------------------------------------------------+
