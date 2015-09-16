//* Copyright notice: This software and it's parts including any included files, except the anything from the "lib" directory is made by and is property of Dynamic Programming Solutions Corporation,
//* while the strategy elements used in it is property of the customer. Any parts can be reused in later software which doesn't violate our Non-Disclosure Agreement.
//* 
//* Non-Disclosure Agreement:
//* We pledge to hold your trading system in confidence.
//* We will not resell your expert advisor that contains your trading ideas, nor will we publish your system specifications.
//* Receipt of your system specifications or other intellectual property by us will effectively constitute a Non-Disclosure Agreement.
//* We have no obligation with respect to such information where the information:
//* 1) was known to us prior to receiving any of the Confidential Information from the customer;
//* 2) has become publicly known through no wrongful act of Recipient;
//* 3) was received by us without breach of this Agreement from a third party without restriction as to the use and disclosure of the information;
//* 4) was independently developed by us without use of the Confidential Information 
//* 
//* The customer has the following rights:
//* 1) Use the software in any instances for personal matters
//* 2) Learn the code and change it
//* 3) Ask any other programmer to make changes, under Non-Disclosure Agreement on the usage of the source code.
//* 4) Resell this EA with possibility to provide the source code under Non-Disclosure Agreement.
//* 5) Make this sofwtare available on website as a free downloadable product WITHOUT providing the source code (i.e. only the ex4 file is downloadable)

#property copyright "Dynamic Programming Solutions Corp."
#property link      "http://www.metatraderprogrammer.com"

#define CUSTOM_SERVICES srvCustom,
#define CUSTOM_CLASSES classCustom,

#include <mtp_framework_1.1\LoaderBase.mqh>

class CCustomServiceBase : public CServiceProvider {
public:
   CCustomServiceBase()
   {
      use_ontick = true;
   }
   virtual void MessageFromCustomService()
   {
      Print("Message From ",__FUNCTION__);
   }
};

#define SERVICE_FASTACCESS_OBJECTS CCustomServiceBase* customservice;
#define SERVICE_FASTACCESS_SWITCH case srvCustom: customservice = service; break;

#include <mtp_framework_1.1\Loader.mqh>
#include <mtp_framework_1.1\DefaultServices.mqh>   
#include <mtp_framework_1.1\ChartInfo\IsFirstTick.mqh>

class CCustomService : public CCustomServiceBase {
public:
   virtual int Type() const { return classCustom; }
   virtual void OnTick()
   {
      if (isfirsttick) {
         Print(__FUNCTION__,": FirstTick");
      }
   }
   virtual void MessageFromCustomService()
   {
      Print("Message From ",__FUNCTION__);
   }
};

/*

ToDo:

Services to add:

SignalHandler
EntryManager
OrderSaving
ScriptHandler

Next Step:
CommentHandler
ActivityManager
LotsizeManager

*/

CApplication app;

void OnTick()
{

   app.OnTick();
   
   if (isfirsttick()) {
   
      app.customservice.MessageFromCustomService();
   
      CSymbolInfoBase* _symbol = app.symbolloader.LoadSymbol(Symbol());
      _symbol.RefreshRates();
      
      COrderManager* om = app.GetService(srvOrderManager);
      om.NewOrder(_symbol.Name(),ORDER_TYPE_BUY,0.1,NULL,new CStopLossTicks(200),new CTakeProfitTicks(200));
      
   }
   
}


int OnInit()
{
   register_services();
   if (!app().ServiceIsRegistered(srvCustom)) app().RegisterService(new CCustomService(),srvCustom,"customservice");

   app.InitalizeServices();

   app.event.SetLogLevel(E_INFO|E_NOTICE|E_WARNING|E_ERROR);
   
   app.event.Info("Message",__FUNCTION__);

   app.OnInit();
   return(0);
}

void OnDeinit(const int reason)
{
   app.OnDeinit();
   return;
}
