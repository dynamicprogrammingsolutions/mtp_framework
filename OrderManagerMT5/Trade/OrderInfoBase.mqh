//+------------------------------------------------------------------+
//|                                                    OrderInfo.mqh |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//|                                              Revision 2010.08.01 |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include "..\..\SymbolLoader\SymbolLoaderMT5.mqh"
//+------------------------------------------------------------------+
//| Class COrderInfo.                                                |
//| Appointment: Class for access to order info.                     |
//|              Derives from class CObject.                         |
//+------------------------------------------------------------------+
class COrderInfoBase : public CObject
  {

public:
   virtual ulong     Ticket()                       { return(0); }
   //--- fast access methods to the integer order propertyes
   virtual datetime          TimeSetup()                    { return(0); }
   virtual ENUM_ORDER_TYPE   OrderType()                     { return(0); }
   virtual string            TypeDescription()               { return(""); }
   virtual ENUM_ORDER_STATE  State()                         { return(0); }
   virtual string            StateDescription()              { return(""); }
   virtual datetime          TimeExpiration()                { return(0); }
   virtual datetime          TimeDone()                      { return(0); }
   virtual ENUM_ORDER_TYPE_FILLING TypeFilling()             { return(0); }
   virtual string                  TypeFillingDescription()  { return(""); }
   virtual ENUM_ORDER_TYPE_TIME    TypeTime()                { return(0); }
   virtual string                  TypeTimeDescription()     { return(""); }
   virtual long              Magic()                         { return(0); }
   virtual long              PositionId()                    { return(0); }
   //--- fast access methods to the double order propertyes
   virtual double            VolumeInitial()                 { return(0); }
   virtual double            VolumeCurrent()                 { return(0); }
   virtual double            PriceOpen()                     { return(0); }
   virtual double            StopLoss()                      { return(0); }
   virtual double            TakeProfit()                    { return(0); }
   virtual double            PriceCurrent()                  { return(0); }
   virtual double            PriceStopLimit()                { return(0); }
   //--- fast access methods to the string order propertyes
   virtual string            Symbol()                        { return(""); }
   virtual string            Comment()                       { return(""); }
   //--- access methods to the API MQL5 functions
   virtual bool              Select(ulong ticket)  { return(0); }
   virtual bool              SelectByIndex(int index)  { return(0); }
};