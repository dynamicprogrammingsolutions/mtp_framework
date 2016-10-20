#include "..\Loader.mqh"
#include "..\TestManager\Loader.mqh"

class CTestSymbolInfo : public CTestBase
{
public:
   CSymbolInfoInterface* symbolinfo;
   string symbol;
   
   CTestSymbolInfo(CSymbolInfoInterface* _symbolinfo, string _symbol)
   {
      symbolinfo = _symbolinfo;
      symbol = _symbol;
   }
   
   virtual void Initalize()
   {
      Prepare(symbolinfo);
   }

   virtual void OnTick()
   {
      
   }
   
   virtual bool OnBeginOnTick()
   {
      Print("SymbolInfo Test Started");
      if (!Assert(symbolinfo.Name(symbol),"loading symbol")) return false;
      Assert(symbolinfo.Name() == symbol,"symbol name");
      symbolinfo.RefreshRates();
      AssertLarger(symbolinfo.Bid(),0,"Bid()");
      AssertLarger(symbolinfo.Ask(),0,"Ask()");
      AssertLarger(symbolinfo.TickSize(),0,"ticksize");
      AssertLarger(symbolinfo.InTicks(symbolinfo.Ask()),0,"InTicks(Ask())");
      AssertLarger(symbolinfo.TickSizeInPoints(),0,"TickSizeInPoints()");
      AssertLargerOrEqual(symbolinfo.StopsLevelInTicks(),0,"StopsLevelInTicks()");
      AssertLargerOrEqual(symbolinfo.MinTakeProfit(),0,"MinTakeProfit()");
      AssertLargerOrEqual(symbolinfo.MinStopLoss(),0,"MinStopLoss()");
      AssertLarger(symbolinfo.SpreadInTicks(),0,"SpreadInTicks()");
      AssertLarger(symbolinfo.SpreadInPrice(),0,"SpreadInPrice()");
      AssertLarger(symbolinfo.LotValue(),0,"LotValue()");
      AssertEqualD(symbolinfo.PriceRound(symbolinfo.Bid()+0.000001),symbolinfo.Bid(),"PriceRound(Bid+0.000001)");
      symbolinfo.LotRoundUp(0.5,false);
      AssertEqualD(symbolinfo.LotRoundUp(),0.5,"LotRoundUp()");      
      AssertEqualD(symbolinfo.LotRound(1.0001),1.0,"LotRound(1.0001)");
      AssertEqualD(symbolinfo.LotRound(0.9999),1.0,"LotRound(0.9999)");
      AssertEqualD(symbolinfo.LotRound(0.0001),0.0,"LotRound(0.0001)");
      symbolinfo.LotRoundUpClose(0.5,false);
      AssertEqualD(symbolinfo.LotRound(1.0001,true),1.0,"LotRound(1.0001,true)");
      AssertEqualD(symbolinfo.LotRound(0.9999,true),1.0,"LotRound(0.9999,true)");
      AssertEqualD(symbolinfo.LotRound(0.0001,true),0.0,"LotRound(0.0001,true)");
      return false;
   }
   
   virtual void OnEnd()
   {
      Print("SymbolInfo Test Ended");
   }    
};
